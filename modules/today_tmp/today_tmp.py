"""Helper script for the ``today-tmp.service`` Systemd unit.

See ``./README.md`` for more information.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

# Date format string, as used by ``datetime.strftime`` and
# ``datetime.strptime``. Used for each day's directory name in the repo,
# and in commit messages.
#
# The logic for determining the latest day parses and compares dates
# chronologically, so this doesn't necessarily need to sort lexically, like
# ISO 8601 does, though I think it's convenient if it does, and you
# probably don't want a ton of baggage anyways, so the default ISO 8601
# should probably be good.
DATE_FMT: str = "%Y-%m-%d"

# Datetime format for filenames, and in particular for generating
# timestamped backup paths (see ``backup_path``); colons aren't allowed in
# Windows paths, so we use underscores instead to avoid potential problems.
# This isn't ISO 8601 compliant but I don't really care, because it has the
# same properties we like from ISO 8601 (regular, sortable, parsable).
FILENAME_DATETIME_FMT: str = "%Y-%m-%dT%H_%M_%S"


def main(args: Optional[Args] = None) -> None:
    """Entry point."""
    if args is None:
        args = Args.parse_args()

    print("Hello!")

    # First, make sure the repo dir exists, and is a Git repository.
    args.repo_path.mkdir(parents=True, exist_ok=True)
    git_init(args.repo_path)  # Only if it's not initialized already.

    # Next, figure out what the current day's directory *should* be.
    date = now().strftime(DATE_FMT)  # Today's date, as a formatted string.
    day_dir = args.repo_path / date  # Today's dir in the repo.

    # Does the day dir exist in the repo?
    day_dir_is_ok = day_dir.exists()

    # Make a new day folder for today.
    if not day_dir.exists():
        print(f"Creating {day_dir}")
        day_dir.mkdir(exist_ok=True, parents=True)

    # Make sure the working path is a symlink to the day_dir
    working_path_is_ok = ensure_symlink_to(args.working_path, day_dir)

    if not args.full and day_dir_is_ok and working_path_is_ok:
        # We're good, print a message and quit
        print(f"{day_dir} already exists and {args.working_path} points to it")

    else:
        # Commit our work to the git repo.
        # Don't worry about empty directories; git doesn't track those.
        git_commit(args.repo_path, ignore_filenames=args.ignore_filenames)

        remove_empty_dirs(
            args.repo_path, other_than=[day_dir], ignore_filenames=args.ignore_filenames
        )

        latest = latest_day_dir(args.repo_path, other_than=[day_dir])

        # If we have a previous day, make a link to it.
        if latest is not None:
            print(f"Previous working path was {latest}")
            prev_link = args.working_path / args.prev_link
            ensure_symlink_to(prev_link, Path(f"../{latest.name}"))

    print("Goodbye!")


def ensure_symlink_to(path: Path, dest: Path) -> bool:
    """Ensure ``path`` is a symlink to ``dest``.

    Returns ``True`` if work was done.
    """
    if not path.parent.exists():
        print("Creating {path.parent}")
        path.parent.mkdir(parents=True)

    if path.is_symlink():
        actual_dest = path.resolve()
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
    """Gets the path of a backup file for ``path``; doesn't move ``path``."""
    basename = path.name + "-" + now().strftime(FILENAME_DATETIME_FMT)
    new_path = path.with_name(basename)
    if new_path.exists():
        raise ValueError(f"Backup path {new_path} already exists")
    return new_path


def remove_empty_dirs(
    path: Path, other_than: Iterable[Path] = (), *, ignore_filenames: Iterable[str]
) -> None:
    """Removes empty child directories of a ``Path``."""
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
            if child_path.name in ignore_filenames:
                ignored.append(child_path)
            else:
                # We found a non-ignored file.
                should_remove = False

        if should_remove:
            print(f"{child} is empty, removing")
            for child_path in ignored:
                child_path.unlink()
            child.rmdir()


def git_init(repo: Path) -> None:
    """Check if ``repo`` is a Git repository, and initialize one if not."""
    proc_is_repo = subprocess.run(
        ["git", "rev-parse", "--is-inside-work-tree"],
        cwd=repo,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if proc_is_repo.returncode != 0:
        proc_init = subprocess.run(
            ["git", "init"],
            cwd=repo,
            check=False,
        )
        if proc_init.returncode != 0:
            print(f"`git init` in {repo} failed. Quitting.")
            sys.exit(1)


def git_commit(repo: Path, *, ignore_filenames: Iterable[str]) -> None:
    """Make a Git commit in ``repo`` if there are local non-ignored changes."""
    if repo.exists():
        # Are any of the changed paths in the repo *not* from files in
        # ``ignore_filenames``?
        if any(path.name not in ignore_filenames for _, path in git_changes(repo)):
            print(f"{repo} has local changes, comitting")
            date = now().strftime(DATE_FMT)
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
    """Get a list of changes in the git repository in ``repo``."""
    proc = subprocess.run(
        ["git", "status", "--porcelain", "--untracked-files"],
        capture_output=True,
        encoding="utf-8",
        check=True,
        cwd=repo,
    )
    return [(line[:2], repo / line[3:]) for line in proc.stdout.strip().splitlines()]


def latest_day_dir(path: Path, other_than: Iterable[Path] = ()) -> Optional[Path]:
    """Gets the latest day in YYYY-mm-dd format."""

    # The date represented by the latest path and the path itself.
    latest: Optional[Tuple[datetime, Path]] = None
    for child in path.iterdir():
        if child in other_than:
            continue

        if not child.is_dir():
            continue

        try:
            date = datetime.strptime(child.name, DATE_FMT)
        except ValueError:
            continue

        if latest is None or date > latest[0]:
            latest = (date, child)

    return None if latest is None else latest[1]


def now() -> datetime:
    """``datetime.now`` wrapper.

    Exposed to be patched when testing.
    """
    return datetime.now()


@dataclass
class Args:
    """Type-safe command-line arguments."""

    repo_path: Path
    """Path to the today_tmp repository containing all the working paths.

    CLI arg: ``--repo-path``

    Example: ``~/.config/today_tmp/repo``
    """

    working_path: Path
    """Path where each day's temporary directory should go.

    CLI arg: ``--working-path``

    Example: ``~/Documents/tmp``
    """

    full: bool = False
    """Perform a full check of the repository.

    CLI switch: ``--full``
    """

    prev_link: str = "prev"
    """Filename of the "previous tmpdir" link in each directory."""

    ignore_filenames = [prev_link]
    """Filenames to ignore in folders in the repo, i.e. in each directory.

    "Ignore" is a bit vague, so to be specific, this mechanism is implemented
    on *top* of the ``.gitignore`` mechanism; these files are ignored by
    today_tmp when we're determining if a folder should be committed or not,
    but are committed and kept in the repo.

    Right now, this is used to ignore the ``prev`` links, and if I ever
    implement ``next`` links they'll be here too.
    """

    @classmethod
    def parse_args(cls) -> Args:
        """Type-safe equivalent to ``argparse.ArgumentParser.parse_args``."""
        args = cls._parser().parse_args()
        return cls(
            repo_path=args.repo_path,
            working_path=args.working_path,
            full=args.full,
        )

    @classmethod
    def _parser(cls) -> argparse.ArgumentParser:
        """Gets the underlying ``ArgumentParser`` for this class."""
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
