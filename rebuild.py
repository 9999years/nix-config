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

from util import cmd, dbg, error, fatal, info, p, show_dbg, warn


def main(args: Optional[Args] = None) -> None:
    """Entry point."""
    if args is None:
        args = Args.parse_args()

    cmd(f"cd {p(args.repo)}")

    if args.pull:
        cmd("git pull --no-edit")
        proc = subprocess.run(
            args.sudo_prefix + ["git", "pull", "--no-edit"], check=False, cwd=args.repo
        )
        if proc.returncode != 0:
            # git pull failed, maybe reset?
            if args.reset:
                cmd(f"git reset --hard {args.remote_branch}")
                proc = subprocess.run(
                    args.sudo_prefix + ["git", "reset", "--hard", args.remote_branch],
                    check=True,
                    cwd=args.repo,
                )
            else:
                fatal("`git pull` failed. Pass `--reset` to reset the repository.")

    info(f"{args.repo} is now at commit:")
    subprocess.run(
        ["git", "log", "HEAD^1..HEAD", "--oneline"], check=False, cwd=args.repo
    )
    cmd("./init.py")
    subprocess.run(args.sudo_prefix + ["./init.py"], check=True, cwd=args.repo)
    rebuild = ["nixos-rebuild", args.rebuild_subcommand] + args.extra_rebuild_args
    cmd(" ".join(rebuild))
    subprocess.run(args.sudo_prefix + rebuild, check=True, cwd=args.repo)


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

    @property
    def sudo_prefix(self) -> List[str]:
        """Arguments to prepend to ``subprocess.run``.

        The arguments call ``sudo`` if ``self.sudo`` is ``True``.
        """
        if self.sudo:
            return ["sudo"] + self.extra_sudo_args
        else:
            return []

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
            "-c",
            "--subcommand",
            default="switch",
            help="""Subcommand to pass to `nixos-rebuild`. Default: "switch".""",
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
            rebuild_subcommand=args.subcommand,
            extra_sudo_args=args.sudo_args,
            extra_rebuild_args=rest,
        )


if __name__ == "__main__":
    main()
