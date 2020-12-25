#! /usr/bin/env nix-shell
#! nix-shell -i python -p python38 gitAndTools.git gitAndTools.delta nixfmt
"""Utility script to help with initializing the repository.

Run ``./init.py --help`` to see options available.
"""

from __future__ import annotations

import argparse
import filecmp
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from util import (
    dbg,
    show_dbg,
    p,
    get_output,
    info,
    warn,
    fatal,
    cmd,
    error,
    BOLD,
    RESET_BOLD,
)

# Line-start regex for new/modified files in the output of
#   `git status --porcelain --untracked-files`
GIT_STATUS_MODIFIED = re.compile(r"\?\?|A | M")

# Touch the filesystem?
DRY_RUN = False


def git_repo_root() -> Path:
    """Gets the git repository root directory.

    Is given relative to this file; it would therefore be unsurprising if this
    function returns the empty path or the current directory path, a single
    dot.
    """
    # dirname is the directory this file is in...
    dirname = Path(__file__).parent
    # ...which we use to determine the repository root.
    dbg("Getting repository root directory.")
    # Don't worry that `relative_to` can raise an exception; we know that this
    # file is in the repository.
    return Path(
        get_output(["git", "rev-parse", "--show-toplevel"], cwd=dirname)
    ).relative_to(dirname.absolute())


def link_configuration(cfg: Path, host_cfg: Path) -> None:
    """Ensure that ``cfg`` is a symlink to ``host_cfg``.

    :param cfg: path to ``configuration.nix``
    :param host_cfg: path to ``hosts/$(hostname)-configuration.nix``
    """
    if cfg.is_symlink():
        cfg_dest = cfg.parent / os.readlink(cfg)
        if cfg_dest.samefile(host_cfg):
            info(f"{p(cfg)} is already a symlink pointing to {p(host_cfg)}")
        else:
            warn(
                f"{p(cfg)} is a symlink pointing to {p(cfg_dest)}, not {p(host_cfg)}; updating it"
            )
            if not DRY_RUN:
                cfg.unlink()
                cfg.symlink_to(host_cfg)

    elif cfg.exists():
        info(
            f"{p(cfg)} already exists and is a regular file; moving it to {p(host_cfg)}"
        )
        if host_cfg.exists():
            fatal(f"{p(host_cfg)} already exists!")
        elif not DRY_RUN:
            cfg.rename(host_cfg)
    else:
        info(f"{p(cfg)} doesn't exist; creating it as a link to {p(host_cfg)}")
        if not DRY_RUN:
            cfg.symlink_to(host_cfg)


def diff_hw_config(hardware_cfg: Path) -> None:
    """Diff changes if we updated the hardware configuration.

    :param hardware_cfg: path to ``hosts/$(hostname)-hardware-configuration.nix``
    """
    # Figure out what would happen if we ran nixos-generate-config.
    info("Diff if `nixos-generate-config` was run:")
    cmd(
        "nixos-generate-config --show-hardware-config "
        + f"| diff --ignore-all-space {hardware_cfg} - "
        + "| delta"
    )
    new_cfg = get_output(["nixos-generate-config", "--show-hardware-config"])
    diff = get_output(
        [
            "diff",
            "--report-identical-files",
            "--new-file",
            "--unified",
            "--ignore-all-space",
            str(hardware_cfg),
            "-",
        ],
        input=new_cfg,
        # 1 just means we found differences
        ok_returncodes=[0, 1],
    )
    delta = subprocess.run(["delta"], input=diff, encoding="utf-8", check=False)
    if delta.returncode != 0:
        warn(f"delta exited with non-zero return code {delta.returncode}")


def update_hw_config_force(hardware_cfg: Path) -> None:
    """Generate and replace the hardware configuration.

    Performs no safety checks, but doesn't write if ``DRY_RUN`` is true.

    :param hardware_cfg: Path to ``hosts/$(hostname)-hardware-configuration.nix`` file to replace.
    """
    info(("Updating " if hardware_cfg.exists() else "Generating ") + p(hardware_cfg))
    cmd(f"nixos-generate-config --show-hardware-config > {hardware_cfg}")
    new_hardware_config = get_output(
        ["nixos-generate-config", "--show-hardware-config"]
    )
    if not DRY_RUN:
        hardware_cfg.write_text(new_hardware_config)


def update_hw_config(args: Args, repo_root: Path, hardware_cfg: Path) -> None:
    """Update ``hardware_cfg``, checking that it's not modified in the repo."""
    dbg("Getting `git status` to check if hardware config has been modified.")
    git_status = get_output(
        ["git", "status", "--porcelain", "--untracked-files"],
        cwd=repo_root,
    ).splitlines()

    # Determine if the local hardware configuration is modified by seeing if
    # any of the modified filenames match it.
    hardware_cfg_modified = any(
        # Slice the string to transform
        #   "  M hosts/dahurica-hardware-configuration.nix"
        #    ^^^^
        #    0123
        # into
        #   "hosts/dahurica-hardware-configuration.nix"
        hardware_cfg.samefile(repo_root / filename[3:])
        for filename in git_status
        if GIT_STATUS_MODIFIED.match(filename)
    )
    dbg(
        "Hardware configuration "
        + ("has" if hardware_cfg_modified else f"has {BOLD}not{RESET_BOLD}")
        + " been modified."
    )

    if hardware_cfg_modified:
        if args.force:
            error(f"There are uncomitted changes to {p(hardware_cfg)};")
            error("refusing to overwrite with `nixos-generate-config`.")
            error("Either commit your changes or pass --force to overwrite local files")
            args.update = False
        else:
            info(
                f"There are uncomitted changes to {p(hardware_cfg)} but "
                + p("--force")
                + " was given; overwriting"
            )

    # We may have updated `args.update` above, so double-check it here.
    if args.update:
        # Note: `DRY_RUN` is handled in `update_hw_config_force`.
        update_hw_config_force(hardware_cfg)


def check_hw_config(host_cfg: Path, hardware_cfg: Path, old_hardware_cfg: Path) -> None:
    """Check that ``hardware_cfg`` exists and ``old_hardware_cfg`` doesn't.

    Also imports ``hardware_cfg`` in ``cfg`` if it's not otherwise imported.
    """
    # `old_hardware_cfg` is repo_root / "hardware-configuration.nix"; NixOS
    # might generate one by default while installing, so this check should stay
    # here even though all of my hosts have been using this script for a while
    # now.
    if old_hardware_cfg.is_symlink():
        warn(
            f"{p(old_hardware_cfg)} is a symlink to "
            + p(hardware_cfg.parent / os.readlink(old_hardware_cfg))
        )
        warn("That's probably not needed; consider deleting it.")

    elif old_hardware_cfg.exists():
        if not hardware_cfg.exists():
            info(
                f"{p(old_hardware_cfg)} exists but {p(hardware_cfg)}"
                + f" doesn't, renaming {p(old_hardware_cfg)}."
            )
            if not DRY_RUN:
                old_hardware_cfg.rename(hardware_cfg)
        else:
            if filecmp.cmp(hardware_cfg, old_hardware_cfg):
                info(
                    f"{p(old_hardware_cfg)} and {p(hardware_cfg)} "
                    + "both exist but have the same contents, removing "
                    + p(old_hardware_cfg)
                )
                if not DRY_RUN:
                    old_hardware_cfg.unlink()
            else:
                error(
                    f"{p(old_hardware_cfg)} and {p(hardware_cfg)} "
                    + "both exist but have different contents."
                )
                error(
                    f"Determine which one is correct and move it to {p(hardware_cfg)}, "
                    + f"and then delete {p(old_hardware_cfg)}"
                )

    # Otherwise, if we don't have a hardware configuration yet, generate one.
    if not hardware_cfg.exists():
        update_hw_config_force(hardware_cfg)

    # `hardware_cfg`, relative to `cfg`, in a nix-import-friendly manner
    hardware_cfg_rel = f"./{hardware_cfg.name}"
    cfg_text = host_cfg.read_text(encoding="utf-8")
    if hardware_cfg_rel in cfg_text:
        dbg(f"It looks like {p(host_cfg)} already imports {p(hardware_cfg)}")
    else:
        info(f"{p(host_cfg)} doesn't import {p(hardware_cfg)}, attempting to add it")
        # Make the substitution...
        new_cfg_text, found_imports = re.subn(
            r"^\s*imports\s*=\s*\[",
            r"\g<0> " + hardware_cfg_rel + " ",
            cfg_text,
            count=1,
            flags=re.MULTILINE,
        )
        if not found_imports:
            error(
                f"Couldn't find a suitable import statement in {p(host_cfg)}; "
                + f"make sure to add an import to {p(hardware_cfg)}"
            )
        else:
            info(f"Writing and reformatting {p(host_cfg)}")
            if not DRY_RUN:
                host_cfg.write_text(new_cfg_text)
                nixfmt_output = get_output(["nixfmt", str(host_cfg)])
                if nixfmt_output:
                    dbg("nixfmt reported:")
                    for line in nixfmt_output.splitlines():
                        dbg(line)


def main(args: Optional[Args] = None) -> None:
    """Entry point."""
    global DRY_RUN  # pylint: disable=global-statement

    if args is None:
        args = Args.parse_args()
    show_dbg(args.verbose)
    DRY_RUN = args.dry_run

    repo_root = git_repo_root()
    os.chdir(repo_root)
    repo_root = Path("")

    cfg = repo_root / "configuration.nix"
    host_cfg = repo_root / "hosts" / (args.hostname + ".nix")
    hardware_cfg = repo_root / "hosts" / (args.hostname + "-hardware-configuration.nix")
    old_hardware_cfg = repo_root / "hardware-configuration.nix"

    dbg(f"hostname                 = {args.hostname}")
    dbg(f"configuration.nix        = {cfg}")
    dbg(f"host's configuration.nix = {host_cfg}")
    dbg(f"hardware configuration   = {hardware_cfg}")

    link_configuration(cfg, host_cfg)
    check_hw_config(host_cfg, hardware_cfg, old_hardware_cfg)

    if args.diff:
        diff_hw_config(hardware_cfg)

    if args.update:
        update_hw_config(args, repo_root, hardware_cfg)

    info("All done! 😃")


@dataclass
class Args:
    """Parsed command-line arguments."""

    verbose: bool
    update: bool
    force: bool
    diff: bool
    hostname: str
    dry_run: bool

    @classmethod
    def parse_args(cls) -> Args:
        """Type-safe wrapper around ``argparse.ArgumentParser.parse_args``."""
        args = cls._parser().parse_args()
        return cls(
            verbose=args.verbose,
            update=args.update,
            force=args.force,
            diff=args.diff,
            hostname=args.hostname
            if args.hostname is not None
            else get_output(["hostname"]),
            dry_run=args.dry_run,
        )

    @classmethod
    def _parser(cls) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            description="initializes the nix-config repository"
        )
        parser.add_argument(
            "--verbose",
            action="store_true",
            help="Include more verbose / debug output",
        )
        parser.add_argument(
            "--dry-run",
            action="store_true",
            help="""
            Don't actually touch the filesystem; no messages are changed, so
            init.py may still act as though it's writing and changing files
            """,
        )
        parser.add_argument(
            "--update",
            action="store_true",
            help="Update the hardware configuration with `nixos-generate-config`",
        )
        parser.add_argument(
            "--force",
            action="store_true",
            help="""
            With --update, overwrite changes to the hardware configuration, even if
            uncommitted changes already exist in the repo.
            """,
        )
        parser.add_argument(
            "--diff",
            action="store_true",
            help="Show what would change if ./init.py was run with --update",
        )
        parser.add_argument(
            "--hostname",
            default=None,
            help="Force a particular hostname rather than whatever `hostname` returns",
        )
        return parser


if __name__ == "__main__":
    main()
