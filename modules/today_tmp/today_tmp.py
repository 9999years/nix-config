from __future__ import annotations

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import List, Optional, cast


def main(args_: Optional[Args] = None):
    if args_ is None:
        args = Args.parse_args(argparser())
    else:
        args = args_

    # - when we log on / every day, check for the latest day in the repo.
    #
    # other stuff:
    # - can we make git know where the repo is?
    # - journald logging?

    date = datetime.now().strftime("%F")  # YYYY-mm-dd
    day_dir = args.repo_path / date
    if (
        day_dir.exists()
        and args.working_path.is_symlink()
        and (args.working_path / os.readlink(args.working_path)) == day_dir
    ):
        # We're good, print a message and quit
        print(f"{day_dir} already exists, nothing to do.")
    else:
        # Commit our work to the git repo.
        # Don't worry about empty directories; git doesn't track those.
        git_commit(args.repo_path)

        remove_empty_dirs(args.repo_path)

        latest = latest_day_dir(args.repo_path)

        # Make a new day folder for today.
        print(f"Creating {day_dir}")
        day_dir.mkdir(exist_ok=True, parents=True)
        if args.working_path.exists():
            if not args.working_path.is_symlink():
                print(f"working path ({args.working_path}) isn't a symlink")
                sys.exit(1)

            # Remove the *link* to the previous day.
            print(f"Unlinking symlink at {args.working_path}")
            args.working_path.unlink()

        args.working_path.parent.mkdir(exist_ok=True, parents=True)
        print(f"Linking {args.working_path} to {day_dir}")
        args.working_path.symlink_to(day_dir)

        # If we have a previous day, make a link to it.
        if latest is not None:
            prev_link = args.working_path / "prev"
            print(f"Linking {prev_link} to {latest}")
            prev_link.symlink_to(latest)


def remove_empty_dirs(path: Path) -> None:
    """Removes empty child directories of a ``Path``.
    """
    for child in path.iterdir():
        if child.is_dir() and not list(child.iterdir()):
            print(f"{child} is empty, removing")
            child.rmdir()


def git_commit(repo: Path):
    if repo.exists():
        if git_has_changes(repo):
            print(f"{repo} has local changes, comitting")
            date = datetime.now().strftime("%F")
            subprocess.run(["git", "add", "."], cwd=repo, check=True)
            subprocess.run(
                [
                    "git",
                    "commit",
                    "-m",
                    date,
                    "-m",
                    f"Temporary / scratch work until {date}",
                ],
                cwd=repo,
                check=True,
            )
    else:
        print(f"{repo} doesn't exist, creating")
        repo.mkdir(parents=True)
        print(f"Running `git init` in {repo}")
        subprocess.run(["git", "init"], cwd=repo, check=True)


def git_has_changes(repo: Path):
    proc = subprocess.run(
        ["git", "status", "--porcelain", "--untracked-files"],
        capture_output=True,
        check=True,
        cwd=repo,
    )
    return not proc.stdout.strip()


def latest_day_dir(path: Path) -> Optional[Path]:
    """Gets the latest day in YYYY-mm-dd format.
    """

    # Safety: This program will never be run before the year 1900.
    # If you set your computer's time to a year before 1900, eat shit.
    sentinel = datetime(1900, 1, 1)
    latest = sentinel
    latest_path = path
    for subdir in path.iterdir():
        try:
            date = datetime.strptime(subdir.name, "%F")
        except ValueError:
            continue

        if date > latest:
            latest = date
            latest_path = subdir

    if latest == sentinel:
        return None
    else:
        return latest_path


@dataclass
class Args:
    repo_path: Path
    working_path: Path

    @classmethod
    def parse_args(cls, parser: argparse.ArgumentParser) -> Args:
        args = parser.parse_args()
        return cls(repo_path=args.repo_path, working_path=args.working_path,)


def argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Manage a daily scratch directory.")
    parser.add_argument("--repo-path", type=Path, help="Path to the main repository.")
    parser.add_argument(
        "--working-path", type=Path, help="Path to the daily temporary directory."
    )

    return parser


if __name__ == "__main__":
    main()
