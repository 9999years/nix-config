"""Constants and functions for logging.

See ``init.py`` and ``rebuild.py`` for use.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import (TYPE_CHECKING, Callable, Iterable, List, NoReturn,
                    Optional, Union, cast)

# Print ``dbg`` calls?
_DEBUG = False

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


def p(path: object) -> str:  # pylint: disable=invalid-name
    """Format an object as a path for terminal output."""
    return UNDERLINED + str(path) + RESET_UNDERLINED


def show_dbg(should_print: bool) -> None:
    """Set the program's debug state.

    If called with ``True``, calls to ``dbg`` will print messages. If called
    with ``False`` or not called, calls to ``dbg`` are no-ops.
    """
    global _DEBUG  # pylint: disable=global-statement
    _DEBUG = should_print


def dbg(msg: str) -> None:
    """Print a message for debugging."""
    if _DEBUG:
        print(f"{GRAY}{DIM}🖝  {msg}{RESET}")


def info(msg: str) -> None:
    """Print an info message."""
    print(f"{BRGREEN}🛈  {msg}{RESET}")


def warn(msg: str) -> None:
    """Print a warning message."""
    print(f"{BRYELLOW}⚠️  {msg}{RESET}")


def error(msg: str) -> None:
    """Print an error message."""
    print(f"{BRRED}⛔ {msg}{RESET}")


def fatal(msg: str) -> NoReturn:
    """Print a fatal error message and exit the program."""
    print(f"{BOLD}{BRRED}💀 [FATAL] {msg}{RESET}")
    sys.exit(1)


def cmd(cmd_: str) -> None:
    """Print a message indicating that a command will be run."""
    print(f"{BOLD}${RESET} {CYAN}{UNDERLINED}{cmd_}{RESET}")


def get_output(  # pylint: disable=too-many-arguments
    args: List[str],
    cwd: Optional[Path] = None,
    log: bool = False,
    strip: bool = True,
    ok_returncodes: Optional[List[int]] = None,
    input: Optional[Union[bytes, str]] = None,  # pylint: disable=redefined-builtin
) -> str:
    """Run a command and return its output.

    A wrapper around ``subprocess.run``.
    """
    if ok_returncodes is None:
        ok_returncodes = [0]

    if log or _DEBUG:
        cmd(" ".join(args))

    proc = subprocess.run(
        args,
        check=False,
        capture_output=True,
        encoding="utf-8",
        cwd=cwd,
        input=input,
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
        return cast(str, proc.stdout.strip())
    else:
        return cast(str, proc.stdout)


if TYPE_CHECKING:
    Process = subprocess.CompletedProcess[Union[str, bytes]]


def run_or_fatal(
    args: List[str],
    returncode: Union[int, Iterable[int]] = 0,
    failed_when: Optional[Callable[[Process], bool]] = None,
    **kwargs: object,
) -> Process:
    """Run a command and fatally error if it fails.

    Keyword-arguments are passed to ``subprocess.run``.

    :param rc: Allowed process return-codes. Ignored if `failed_when` is not None.
    """
    proc: Process = subprocess.run(args, check=False, **kwargs)  # type: ignore  # sorry
    failed = False
    if failed_when is not None:
        failed = failed_when(proc)
    else:
        if isinstance(returncode, int):
            failed = proc.returncode != returncode
        elif proc.returncode not in returncode:
            failed = True

    if failed:
        fatal(f"Process {' '.join(args)} failed.")

    return proc
