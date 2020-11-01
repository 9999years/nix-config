#! /usr/bin/env nix-shell
#! nix-shell -i python -p python38 gitAndTools.git gitAndTools.delta nixfmt

from __future__ import annotations

import argparse
import filecmp
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, NoReturn, Optional, Union

# Line-start regex for new/modified files in the output of
#   `git status --porcelain --untracked-files`
GIT_STATUS_MODIFIED = re.compile(r"\?\?|A | M")

# Include debug output?
DEBUG = False

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
        info(
            f"{p('configuration.nix')} is already a symlink pointing to {p(cfg.parent / os.readlink(cfg))}"
        )
    elif cfg.exists():
        info(
            f"{p('configuration.nix')} already exists and is a regular file; moving it to {p(host_cfg)}"
        )
        if host_cfg.exists():
            fatal(f"{p(host_cfg)} already exists!")
        elif not DRY_RUN:
            cfg.rename(host_cfg)
    else:
        info(
            f"{p('configuration.nix')} doesn't exist; creating it as a link to {p(host_cfg)}"
        )
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


def update_hw_config_force(hardware_cfg: Path):
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


def update_hw_config(args: Args, repo_root: Path, hardware_cfg: Path):
    """Update ``hardware_cfg``, checking that it's not modified in the repo.
    """
    dbg("Getting `git status` to check if hardware config has been modified.")
    git_status = get_output(
        ["git", "status", "--porcelain", "--untracked-files"], cwd=repo_root,
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
                f"There are uncomitted changes to {p(hardware_cfg)} but {p('--force')} was given; overwriting"
            )

    # We may have updated `args.update` above, so double-check it here.
    if args.update:
        # Note: `DRY_RUN` is handled in `update_hw_config_force`.
        update_hw_config_force(hardware_cfg)


def check_hw_config(host_cfg: Path, hardware_cfg: Path, old_hardware_cfg: Path):
    """Check that ``hardware_cfg`` exists and ``old_hardware_cfg`` doesn't.

    Also imports ``hardware_cfg`` in ``cfg`` if it's not otherwise imported.
    """
    if old_hardware_cfg.is_symlink():
        warn(
            f"{p(hardware_cfg)} is a symlink to {p(hardware_cfg.parent / os.readlink(old_hardware_cfg))}"
        )
        warn("That's probably not needed; consider deleting it.")
    elif old_hardware_cfg.exists():
        if not hardware_cfg.exists():
            info(
                f"{p(old_hardware_cfg)} exists but {p(hardware_cfg)} doesn't, renaming {p(old_hardware_cfg)}."
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
                dbg("nixfmt reported:")
                for line in nixfmt_output.splitlines():
                    dbg(line)


def main():
    global DEBUG, DRY_RUN
    args = Args.parse_args(argparser())
    DEBUG = args.verbose
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


@dataclass
class Args:
    """Parsed command-line arguments.
    """

    verbose: bool
    update: bool
    force: bool
    diff: bool
    hostname: str
    dry_run: bool

    @classmethod
    def parse_args(cls, parser: argparse.ArgumentParser):
        args = parser.parse_args()
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


def argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="initializes the nix-config repository"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Include more verbose / debug output",
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


RESET = "\x1b[0m"
BOLD = "\x1b[1m"
RESET_BOLD = "\x1b[21m"
DIM = "\x1b[2m"
RESET_DIM = "\x1b[22m"
UNDERLINED = "\x1b[4m"
RESET_UNDERLINED = "\x1b[24m"

RED = "\x1b[31m"
BRRED = "\x1b[91m"
GREEN = "\x1b[32m"
BRGREEN = "\x1b[92m"
YELLOW = "\x1b[33m"
BRYELLOW = "\x1b[93m"
BLUE = "\x1b[34m"
BRBLUE = "\x1b[94m"
PURPLE = "\x1b[35m"
BRPURPLE = "\x1b[95m"
CYAN = "\x1b[36m"
BRCYAN = "\x1b[96m"
GRAY = "\x1b[37m"
BRGRAY = "\x1b[97m"
RESET_FG = "\x1b[39m"


def p(path: object) -> str:
    """Format an object as a path for terminal output.
    """
    return UNDERLINED + str(path) + RESET_UNDERLINED


def dbg(msg: str) -> None:
    if DEBUG:
        print(f"{GRAY}{DIM}🖝  {msg}{RESET}")


def info(msg: str) -> None:
    print(f"{BRGREEN}🛈  {msg}{RESET}")


def warn(msg: str) -> None:
    print(f"{BRYELLOW}⚠️  {msg}{RESET}")


def error(msg: str) -> None:
    print(f"{BRRED}⛔ {msg}{RESET}")


def fatal(msg: str) -> NoReturn:
    print(f"{BOLD}{BRRED}💀 [FATAL] {msg}{RESET}")
    sys.exit(1)


def cmd(cmd_: str) -> None:
    print(f"{BOLD}${RESET} {CYAN}{UNDERLINED}{cmd_}{RESET}")


def get_output(
    args: List[str],
    cwd: Optional[Path] = None,
    log: bool = False,
    strip: bool = True,
    ok_returncodes: List[int] = [0],
    input: Optional[Union[bytes, str]] = None,
) -> str:
    if log or DEBUG:
        cmd(" ".join(args))

    proc = subprocess.run(
        args, check=False, capture_output=True, encoding="utf-8", cwd=cwd, input=input,
    )

    if proc.returncode not in ok_returncodes:
        msg = (
            UNDERLINED
            + " ".join(args)
            + RESET_UNDERLINED
            + f" exited with code {proc.returncode}."
        )

        if proc.stdout:
            msg += f"\nstdout: {proc.stdout}"

        if proc.stderr:
            msg += f"\nstderr: {proc.stdout}"

        fatal(msg)

    if proc.stderr:
        dbg(f"{args[0]} wrote to stderr: {proc.stderr}")

    if strip:
        return proc.stdout.strip()
    else:
        return proc.stdout


if __name__ == "__main__":
    main()
