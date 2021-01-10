"""Tests for ``today_tmp``.
"""

# pylint: disable=redefined-outer-name

from __future__ import annotations

import os
import subprocess
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Iterator, List, Any, cast
from unittest.mock import patch
import re

import pytest

import today_tmp
from today_tmp import Args

Fixture = Iterator

# Repo directory name in the ``tmpdir`` fixture.
REPO_DIR = "repo"
# Working directory in the ``tmpdir`` fixture.
WORK_DIR = "tmp"

# "Now", for testing purposes.
NOW = datetime(2021, 1, 10, 16, 20, 0)


@dataclass
class TodayTmp:
    """Test directory utility class for testing ``today_tmp``."""

    root: Path
    """Root temporary directory."""

    repo: Path
    """Repository."""

    work: Path
    """Working directory."""

    _now: datetime = field(default=NOW, init=False)
    """What ``today_tmp`` sees as the current time.
    """

    @property
    def now(self) -> datetime:
        """What ``today_tmp`` sees as the current time."""
        return self._now

    @now.setter
    def now(self, now: datetime) -> None:
        self._now = now

    def tomorrow(self) -> None:
        """Go to tomorrow by incrementing ``self.now`` by one day."""
        self.now += timedelta(days=1)

    def args(self, full: bool = False) -> Args:
        """Arguments for running ``today_tmp.main``."""
        return Args(
            repo_path=self.repo,
            working_path=self.work,
            full=full,
        )

    def run(self, full: bool = False, tomorrow: bool = False) -> None:
        """Runs ``today_tmp.main``.

        See ``args`` for argument construction.

        :param tomorrow: Should we call ``self.tomorrow`` before running today_tmp?
        """
        if tomorrow:
            self.tomorrow()

        with patch.object(today_tmp, "now", return_value=self.now) as _mock:
            today_tmp.main(self.args(full))


def print_tree() -> None:
    """Prints a tree of the current directory."""
    subprocess.run(["tree", "-C"], check=True)


@pytest.fixture(name="today")
def today_fixture() -> Fixture[TodayTmp]:
    """Fixture yielding a temporary directory after ``os.chdir``ing into it."""
    with TemporaryDirectory() as tmpdir_name:
        root = Path(tmpdir_name)
        old_cwd = os.getcwd()
        os.chdir(root)
        today = TodayTmp(
            root=root,
            repo=root / "repo",
            work=root / "tmp",
        )
        today.run()  # Set up the repo / directories
        yield today
        os.chdir(old_cwd)


def readlink(path: Path) -> Path:
    """Read the symbolic link destination of ``path``."""
    return Path(os.readlink(path))


def test_prev_regression(today: TodayTmp) -> None:
    """When run twice in a row, the "prev" link pointed to the current directory.

    Make sure that doesn't happen again.
    """
    # Do some "work"
    (today.work / "silly-script.sh").write_text(
        """
        #!/bin/bash
        echo "hi friend :)"
        """
    )

    # Run today_tmp the next day; this commits our work, because we swap out
    # the day directories.
    today.run(tomorrow=True)
    today.run()

    assert (today.repo / "2021-01-10") == readlink(today.work / "prev")


def test_commits(today: TodayTmp) -> None:
    """today_tmp runs ``git commit``."""
    git_log = ["git", "log", "--oneline"]

    def git_log_stdout() -> str:
        return subprocess.run(
            git_log, capture_output=True, encoding="utf-8", cwd=today.repo, check=True
        ).stdout.strip()

    # Check: No commits yet.
    proc = subprocess.run(
        git_log, capture_output=True, encoding="utf-8", cwd=today.repo, check=False
    )
    assert proc.returncode == 128
    assert re.fullmatch(
        r"fatal: your current branch '[a-zA-Z0-9/_-]+' does not have any commits yet",
        proc.stderr.strip(),
    )

    # Do some work...
    (today.work / "foo").write_text("foo")
    # Run today_tmp again to make a commit
    today.run(tomorrow=True)

    # Check that we have a commit
    stdout_1 = git_log_stdout()
    assert re.fullmatch("[0-9a-f]{7} 2021-01-11", stdout_1)

    # We didn't do anything, so this *shouldn't* make a commit.
    today.run(tomorrow=True)
    assert git_log_stdout() == stdout_1


def test_delete_empty(today: TodayTmp) -> None:
    """today_tmp should delete old empty directories."""
    (today.work / "puppy").write_text("dog")  # In 2021-01-11, write a file.
    today.run(tomorrow=True)  # 2021-01-11
    today.run(tomorrow=True)  # 2021-01-12
    today.run(tomorrow=True)  # 2021-01-13
    today.run(tomorrow=True)  # 2021-01-14
    assert set(today.repo.iterdir()) == {
        today.repo / ".git",
        today.repo / "2021-01-10",  # First day.
        today.repo / "2021-01-14",  # Current day.
    }
    assert set((today.repo / "2021-01-10").iterdir()) == {
        today.repo / "2021-01-10" / "puppy",
    }
    assert set((today.repo / "2021-01-14").iterdir()) == {
        today.repo / "2021-01-14" / "prev",
    }
    assert readlink(today.work) == today.repo / "2021-01-14"
    assert readlink(today.work / "prev") == today.repo / "2021-01-10"
