from __future__ import annotations

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable, List, Optional, Tuple, cast

# ISO 8601 date.
DATE_FMT = "%Y-%m-%d"
# Datetime format for filenames; colons aren't allowed in Windows paths, so we
# use underscores instead to avoid potential problems.
FILENAME_DATETIME_FMT = "%Y-%m-%dT%H_%M_%S"
PREV_LINK = "prev"
# Basenames to ignore in tmp folders; used to ignore "prev" links right now,
# could be used to ignore "next" links as well.
IGNORE_FILES = [PREV_LINK]


def main(args_: Optional[Args] = None) -> None:
    if args_ is None:
        args = Args.parse_args()
    else:
        args = args_

    date = datetime.now().strftime(DATE_FMT)
    day_dir = args.repo_path / date
    day_dir_is_ok = day_dir.exists()
    working_path_is_ok = ensure_symlink_to(args.working_path, day_dir)
    if day_dir_is_ok and working_path_is_ok:
        # We're good, print a message and quit
        print(f"{day_dir} already exists, nothing to do.")

    if args.full or not day_dir_is_ok or not working_path_is_ok:
        # Commit our work to the git repo.
        # Don't worry about empty directories; git doesn't track those.
        git_commit(args.repo_path)

        remove_empty_dirs(args.repo_path, other_than=[day_dir])

        latest = latest_day_dir(args.repo_path)

        # Make a new day folder for today.
        if not day_dir_is_ok:
            print(f"Creating {day_dir}")
            day_dir.mkdir(exist_ok=True, parents=True)

        # If we have a previous day, make a link to it.
        if latest is not None:
            print(f"Previous working path was {latest}")
            prev_link = args.working_path / PREV_LINK
            ensure_symlink_to(prev_link, latest)


def ensure_symlink_to(path: Path, dest: Path) -> bool:
    """Ensure ``path`` is a symlink to ``dest``.

    Returns ``True`` if work was done.
    """
    if not path.parent.exists():
        print("Creating {path.parent}")
        path.parent.mkdir(parents=True)

    if path.is_symlink():
        actual_dest = path.parent / os.readlink(path)
        if actual_dest == dest:
            print(f"{path} is already a link to {dest}")
            return False
        else:
            print(f"{path} is a link to {actual_dest} instead of {dest}")
            path.unlink()
    elif path.exists():
        backup = backup_path(path)
        print(f"Renaming {path} to {backup}")
        path.rename(backup)

    print(f"Linking {path} to {dest}")
    path.symlink_to(dest)
    return True


def backup_path(path: Path) -> Path:
    basename = path.name + "-" + datetime.now().strftime(FILENAME_DATETIME_FMT)
    new_path = path.with_name(basename)
    if new_path.exists():
        raise ValueError(f"Backup path {new_path} already exists")
    return new_path


def remove_empty_dirs(path: Path, other_than: Iterable[Path] = ()) -> None:
    """Removes empty child directories of a ``Path``.
    """
    for child in path.iterdir():
        if child in other_than:
            continue

        if not child.is_dir():
            continue

        # We have some files like prev links that are "ignored" in the sense
        # that they don't constitute "use" of a temporary folder, but we don't
        # want to ignore them in git, so we do some workarounds here.
        #
        # Additionally, if we try to `rmdir` on a `Path` with ignored files in
        # it, we get a non-empty error; therefore, we have to figure out if
        # there's ignored files in the directory (and if so, which ones), if
        # there's other files, and then remove the directory after the ignored
        # files.
        #
        # This kinda sucks and I'd like to replace it. with something that
        # makes me feel less sketchy.
        should_remove = True

        ignored: List[Path] = []
        for child_path in child.iterdir():
            if child_path.name in IGNORE_FILES:
                ignored.append(child_path)
            else:
                # We found a non-ignored file.
                should_remove = False

        if should_remove:
            print(f"{child} is empty, removing")
            for child_path in ignored:
                child_path.unlink()
            child.rmdir()


def git_commit(repo: Path) -> None:
    if repo.exists():
        changes = any(path.name not in IGNORE_FILES for _, path in git_changes(repo))
        if changes:
            print(f"{repo} has local changes, comitting")
            date = datetime.now().strftime(DATE_FMT)
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
            print(f"{repo} has no local changes")
    else:
        print(f"{repo} doesn't exist, creating")
        repo.mkdir(parents=True)
        print(f"Running `git init` in {repo}")
        subprocess.run(["git", "init"], cwd=repo, check=True)


def git_changes(repo: Path) -> List[Tuple[str, Path]]:
    proc = subprocess.run(
        ["git", "status", "--porcelain", "--untracked-files"],
        capture_output=True,
        encoding="utf-8",
        check=True,
        cwd=repo,
    )
    return [(line[:2], repo / line[3:]) for line in proc.stdout.strip().splitlines()]


def latest_day_dir(path: Path) -> Optional[Path]:
    """Gets the latest day in YYYY-mm-dd format.
    """

    # The date represented by the latest path and the path itself.
    latest: Optional[Tuple[datetime, Path]] = None
    for subdir in path.iterdir():
        try:
            date = datetime.strptime(subdir.name, DATE_FMT)
        except ValueError:
            continue

        if latest is None or date > latest[0]:
            latest = (date, subdir)

    return None if latest is None else latest[1]


@dataclass
class Args:
    """Command-line arguments.
    """

    repo_path: Path
    working_path: Path
    full: bool

    @classmethod
    def parse_args(cls) -> Args:
        args = cls.parser().parse_args()
        return cls(
            repo_path=args.repo_path, working_path=args.working_path, full=args.full,
        )

    @classmethod
    def parser(cls) -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            description="Manage a daily scratch directory."
        )
        parser.add_argument(
            "--repo-path", type=Path, help="Path to the main repository."
        )
        parser.add_argument(
            "--working-path", type=Path, help="Path to the daily temporary directory."
        )
        parser.add_argument(
            "--full",
            action="store_true",
            help="""Perform a full check; this removes empty directories, makes a
            git commit if there's new work, etc. even if today's directory already
            exists.""",
        )

        return parser


if __name__ == "__main__":
    main()
