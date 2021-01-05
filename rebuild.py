#! /usr/bin/env nix-shell
#! nix-shell -i python -p python38
"""Script for rebuilding the NixOS configuration.

Run `./rebuild.py --help` for options.
"""

# Unported part of the fish function used for non-NixOS rebuilds:
#  if is_darwin
#  set __nix_pkg_expr "$HOME/.config/nix-config/macos.nix"
#  echo -s (set_color --bold --underline) "On MacOS; building environment from $__nix_pkg_expr" (set_color normal)
#  echo "Installing:"
#  nix-instantiate --eval --strict \
#  --expr "builtins.map (p: p.name) (import $__nix_pkg_expr {})"
#  nix-env --install --remove-all --file "$__nix_pkg_expr"

from __future__ import annotations

import argparse
import os
import shlex
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional
from tempfile import TemporaryDirectory

from util import cmd, dbg, error, fatal, info, p, run_or_fatal, show_dbg, warn

# Subcommands for `nixos-rebuild`.
# See: `man 8 nixos-rebuild`.
REBUILD_SUBCOMMANDS = [
    "switch",
    "build",
    "boot",
    "test",
    "dry-build",
    "dry-activate",
    "edit",
    "build-vm",
    "build-vm-with-bootloader",
]


def main(args: Optional[Args] = None) -> None:
    """Entry point."""
    if args is None:
        args = Args.parse_args()

    # Okay, so we don't actually use `os.chdir` here. Why? If we split a panel
    # while rebuilding (or open a new window), tmux starts the new shell in the
    # current process' cwd. Therefore, so we don't end up accidentally mucking
    # around in `/etc/nixos`, we don't change the cwd and instead use
    # `cwd=args.repo` for `subprocess.run` invocations.
    cmd(f"cd {p(args.repo)}")

    if args.fix_full_boot:
        fix_full_boot(args)

    pull(args)
    rebuild(args.rebuild_args, args.sudo_prefix, args.repo)


def pull(args: Args) -> None:
    """Update ``args.repo`` with ``git pull``."""
    if args.pull:
        cmd("git pull --no-edit")
        proc = subprocess.run(
            args.sudo_prefix + ["git", "pull", "--no-edit"], check=False, cwd=args.repo
        )
        if proc.returncode != 0:
            # git pull failed, maybe reset?
            if args.reset:
                run_or_fatal(
                    args.sudo_prefix + ["git", "reset", "--hard", args.remote_branch],
                    log=True,
                    cwd=args.repo,
                )
            else:
                fatal("`git pull` failed. Pass `--reset` to reset the repository.")

    info(f"{args.repo} is now at commit:")
    subprocess.run(
        ["git", "log", "HEAD^1..HEAD", "--oneline"], check=False, cwd=args.repo
    )


def rebuild(
    rebuild_args: List[str],
    sudo_prefix: List[str],
    repo: Path,
    rebuild_cwd: Optional[Path] = None,
) -> None:
    """Run ``nixos-rebuild``."""
    if rebuild_cwd is None:
        rebuild_cwd = repo

    run_or_fatal(sudo_prefix + ["./init.py"], log=True, cwd=repo)
    run_or_fatal(
        rebuild_args,
        log=True,
        cwd=rebuild_cwd,
    )


def fix_full_boot(args: Args) -> None:
    """Fixes 'no space left on device' error by deleting old generations."""
    info(
        "Cleaning up full /boot partition; removing old generations and garbage-collecting the Nix store."
    )

    # Before we try `./rebuild.py --fix-full-boot`, we probably built the whole
    # profile but couldn't switch to it. We're going to run the Nix garbage
    # collector, so we're going to do a plain `nixos-rebuild build` to prevent
    # the newly-built profile from being deleted, forcing us to recompile all
    # our work and wasting a lot of time.
    with TemporaryDirectory() as tmpdir:
        # Temporarily set `args.rebuild_subcommand` to `build`.
        old_rebuild_subcommand, args.rebuild_subcommand = (
            args.rebuild_subcommand,
            "build",
        )
        rebuild(
            rebuild_args=args.rebuild_args,
            sudo_prefix=args.sudo_prefix,
            repo=args.repo,
            rebuild_cwd=Path(tmpdir),
        )
        # Undo changing `args.rebuild_subcommand`.
        args.rebuild_subcommand = old_rebuild_subcommand

        profile_path = os.readlink(os.path.join(tmpdir, "result"))
        info(f"Newly-built profile: {p(profile_path)}")

        # Collect garbage.
        # TODO: Are these commented out commands needed?
        # run_or_fatal(args.sudo_prefix + ["nix-env", "--delete-generations", "old"])
        # run_or_fatal(args.sudo_prefix + ["nix-env", "--profile", "/nix/var/nix/profiles/system",
        # "--delete-generations", "old"])
        run_or_fatal(
            args.sudo_prefix + ["nix-collect-garbage", "--delete-old"], log=True
        )


@dataclass
class Args:
    """Parsed command-line arguments."""

    repo: Path
    remote_branch: str
    reset: bool
    pull: bool
    sudo: bool
    rebuild_subcommand: str
    extra_rebuild_args: List[str]
    extra_sudo_args: List[str]
    fix_full_boot: bool

    @property
    def sudo_prefix(self) -> List[str]:
        """Arguments to prepend to ``subprocess.run``.

        The arguments call ``sudo`` if ``self.sudo`` is ``True``.
        """
        if self.sudo:
            return ["sudo"] + self.extra_sudo_args
        else:
            return []

    @property
    def rebuild_args(self) -> List[str]:
        """Arguments to run ``nixos-rebuild``."""
        return (
            self.sudo_prefix
            + ["nixos-rebuild", self.rebuild_subcommand]
            + self.extra_rebuild_args
        )

    @classmethod
    def _argparser(cls) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            description="""Rebuilds the current NixOS configuration.
            Unrecognized arguments are passed to `nixos-rebuild`.
            """,
        )
        parser.add_argument(
            "--repo",
            type=Path,
            default="/etc/nixos",
            help="""The path to the authoritative repository to build the
            configuration from. Default: "/etc/nixos".""",
        )
        parser.add_argument(
            "-r",
            "--reset",
            action="store_true",
            help="""If given and `git pull` fails, reset to the origin branch
            instead of failing.""",
        )
        parser.add_argument(
            "--no-pull",
            action="store_false",
            dest="pull",
            help="If given, don't `git pull` in the repo.",
        )
        parser.add_argument(
            "--no-sudo",
            action="store_false",
            dest="sudo",
            help="If given, don't run commands through `sudo`",
        )
        parser.add_argument(
            "--sudo-args",
            type=shlex.split,
            default=[],
            help="""Extra arguments to add to `sudo`; parsed with `shlex.split`.""",
        )
        parser.add_argument(
            "--remote-branch",
            default="origin/main",
            help="""Remote branch to reset to, if needed. Default: "origin/main".""",
        )
        parser.add_argument(
            "-f",
            "--fix-full-boot",
            action="store_true",
            help="""Fix the 'no space left on device' error when switching to a
            new configuration; deletes old profiles before rebuilding.""",
        )
        return parser

    @classmethod
    def parse_args(cls) -> Args:
        """Type-safe wrapper around ``argparse.ArgumentParser.parse_args``."""
        args, rest = cls._argparser().parse_known_args()
        return cls(
            repo=args.repo,
            remote_branch=args.remote_branch,
            reset=args.reset,
            pull=args.pull,
            sudo=args.sudo,
            rebuild_subcommand=cls._rebuild_subcommand(rest),
            extra_sudo_args=args.sudo_args,
            extra_rebuild_args=rest,
            fix_full_boot=args.fix_full_boot,
        )

    @classmethod
    def _rebuild_subcommand(cls, extra_rebuild_args: List[str]) -> str:
        for arg in extra_rebuild_args:
            if arg in REBUILD_SUBCOMMANDS:
                return arg
        # Default: switch to the new configuration.
        return "switch"


if __name__ == "__main__":
    main()
