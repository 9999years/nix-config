#! /usr/bin/env nix-shell
#! nix-shell -i python -p python38 gitAndTools.git gitAndTools.delta

import argparse
import os
import subprocess
import sys
from pathlib import Path
from typing import List, NoReturn
import re
from dataclasses import dataclass

# Line-start regex for new/modified files in the output of
#   `git status --porcelain --untracked-files`
GIT_STATUS_MODIFIED = re.compile(r"\?\?|A | M")


def main():
    args = Args.parse_args(argparser())

    dirname = Path(__file__).parent
    cfg = dirname / "configuration.nix"
    dbg(f"cfg = {cfg}")
    hostname = args.hostname
    host_cfg = dirname / "hosts" / (hostname + ".nix")
    dbg(f"host_cfg = {host_cfg}")

    # configuration.nix link
    if cfg.is_symlink():
        info(
            f"{p('configuration.nix')} is already a symlink pointing to {p(dirname / os.readlink(cfg))}"
        )
    elif cfg.exists():
        info(
            f"{p('configuration.nix')} already exists and is a regular file; moving it to {p(host_cfg)}"
        )
        if host_cfg.exists():
            fatal(f"{p(host_cfg)} already exists!")
        else:
            cfg.rename(host_cfg)
    else:
        info(
            f"{p('configuration.nix')} doesn't exist; creating it as a link to {p(host_cfg)}"
        )
        cfg.symlink_to(host_cfg)

    hardware_config = dirname / "hosts" / (hostname + "-hardware-configuration.nix")
    if args.diff:
        # Figure out what would happen if we ran nixos-generate-config.
        new_cfg = get_output(["nixos-generate-config", "--show-hardware-config"])
        diff = subprocess.run(
            [
                "diff",
                "--report-identical-files",
                "--new-file",
                "--unified",
                "--ignore-all-space",
                str(hardware_config),
                "-",
            ],
            input=new_cfg,
            capture_output=True,
            encoding="utf-8",
            check=False,
        )
        if diff.returncode not in [0, 1]:
            fatal(
                f"diffing current hardware-configuration.nix with new hardware configuration failed: {diff.stderr}"
            )
        info("Diff if `nixos-generate-config` was run:")
        subprocess.run(["delta"], input=diff.stdout, encoding="utf-8", check=False)

    dbg("Getting repository root directory.")
    git_repo_root = get_output(["git", "rev-parse", "--show-toplevel"])
    dbg("Getting `git status` to check if hardware config has been modified.")
    git_status = get_output(
        ["git", "status", "--porcelain", "--untracked-files"]
    ).splitlines()
    dbg(f"git_repo_root = {git_repo_root}")
    dbg(f"hardware_config = {hardware_config}")
    hardware_config_relative = hardware_config.absolute().relative_to(git_repo_root)
    dbg(f"hardware_config_relative = {hardware_config_relative}")
    hardware_config_modified = any(
        # Slice the string to transform
        #   "  M hosts/dahurica-hardware-configuration.nix"
        #    ^^^^
        #    0123
        # into
        #   "hosts/dahurica-hardware-configuration.nix"
        hardware_config_relative.samefile(filename[3:])
        for filename in git_status
        if GIT_STATUS_MODIFIED.match(filename)
    )
    dbg(
        "Hardware config "
        + ("has" if hardware_config_modified else "has not")
        + " been modified."
    )

    if args.update:
        if hardware_config_modified:
            if args.force:
                error("There are uncomitted changes to {p(hardware_config)};")
                error("refusing to overwrite with `nixos-generate-config`.")
                error(
                    "Either commit your changes or pass --force to overwrite local files"
                )
                args.update = False
            else:
                info(
                    f"There are uncomitted changes to {p(hardware_config)} but {p('--force')} was given; overwriting"
                )

        # We may have updated `args.update` above, so double-check it here.
        if args.update:
            info(f"Updating {p(hardware_config)}")
            cmd(f"nixos-generate-config --show-hardware-config > {hardware_config}")
            new_hardware_config = get_output(
                ["nixos-generate-config", "--show-hardware-config"]
            )
            with open(hardware_config, "w") as hardware_config_fh:
                hardware_config_fh.write(new_hardware_config)

        # lines 155 and on of init.sh


@dataclass
class Args:
    """Parsed command-line arguments.
    """

    update: bool
    force: bool
    diff: bool
    hostname: str

    @classmethod
    def parse_args(cls, parser: argparse.ArgumentParser):
        args = parser.parse_args()
        return cls(
            update=args.update,
            force=args.force,
            diff=args.diff,
            hostname=args.hostname
            if args.hostname is not None
            else get_output(["hostname"]),
        )


def argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="initializes the nix-config repository"
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


def get_output(args: List[str], log: bool = False, strip: bool = True) -> str:
    if log:
        cmd(" ".join(args))

    proc = subprocess.run(args, check=False, capture_output=True, encoding="utf-8")

    if proc.returncode != 0:
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

    if strip:
        return proc.stdout.strip()
    else:
        return proc.stdout


if __name__ == "__main__":
    main()
