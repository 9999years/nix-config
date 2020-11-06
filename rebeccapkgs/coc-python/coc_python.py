#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Optional


def main():
    args = Args.parse_args(argparser())
    root = try_git_root()

    if root is None:
        # Couldn't get the git root; try parents of the current dir.
        cwd = Path.cwd()
        for maybe_root in cwd.parents:
            vim_dir = maybe_root / ".vim"
            if vim_dir.exists():
                root = maybe_root

        # No parents of the current dir already work; just use the
        # current dir.
        if root is None:
            root = cwd

    vim_dir = root / ".vim"
    vim_dir.mkdir(parents=True, exist_ok=True)

    coc_settings_path = vim_dir / "coc-settings.json"
    if coc_settings_path.exists():
        with open(coc_settings_path) as coc_settings_file:
            coc_settings: Dict[str, Any] = json.load(coc_settings_file)

    new_coc_settings = {
        "python.formatting.autopep8Path": args.py_bin("autopep8"),
        "python.formatting.blackPath": args.py_bin("black"),
        "python.formatting.yapfPath": args.py_bin("yapf"),
        "python.linting.flake8Path": args.py_bin("flake8"),
        "python.linting.banditPath": args.py_bin("bandit"),
        "python.linting.mypyPath": args.py_bin("mypy"),
        "python.linting.pep8Path": args.py_bin("pep8"),
        "python.linting.pydocstylePath": args.py_bin("pydocstyle"),
        "python.linting.pylamaPath": args.py_bin("pylama"),
        "python.linting.pylintPath": args.py_bin("pylint"),
        "python.poetryPath": args.py_bin("poetry"),
        "python.condaPath": args.py_bin("conda"),
        "python.sortImports.path": args.py_bin("isort"),
        "python.pythonPath": args.py_bin("python"),
    }

    if args.pipenv is not None:
        new_coc_settings["python.pipenvPath"] = args.pipenv

    if args.ctags is not None:
        new_coc_settings["python.workspaceSymbols.ctagsPath"] = args.ctags

    modified = False
    for key, val in new_coc_settings.items():
        old_val = coc_settings.get(key, None)
        if old_val != val:
            if not modified:
                print("Updating settings in", coc_settings_path)
            modified = True

            if old_val is None:
                print("Setting", key, "to", val)
            else:
                print("Updating", key)
                print(" old:", old_val)
                print(" new:", val)

            if isinstance(val, Path):
                coc_settings[key] = str(val)
            else:
                coc_settings[key] = val

    if modified:
        # We need to write the file.

        # If we had a previous file, back it up.
        if coc_settings_path.exists():
            coc_settings_path_backup = coc_settings_path.with_suffix(".json.bak")
            print("Saving old coc settings to", coc_settings_path_backup)
            coc_settings_path.rename(coc_settings_path_backup)

        # Write the new file.
        with open(coc_settings_path) as coc_settings_file:
            json.dump(coc_settings, coc_settings_file, indent=True, sort_keys=True)


def try_git_root() -> Optional[Path]:
    """Returns the Git repo root or None.
    """
    try:
        proc = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            check=False,
            capture_output=True,
            encoding="utf-8",
        )
    except FileNotFoundError:
        # No Git executable
        return None

    if proc.returncode != 0:
        return None

    out = proc.stdout.strip()
    return Path(out)


@dataclass
class Args:
    python: Path
    pipenv: Optional[Path]
    ctags: Optional[Path]

    def py_bin(self, exe_name: str) -> Path:
        return self.python / "bin" / exe_name

    @classmethod
    def parse_args(cls, parser: argparse.ArgumentParser) -> Args:
        args = parser.parse_args()
        return cls(python=args.python, pipenv=args.pipenv, ctags=args.ctags)


def argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Initializes a CoC environment for Python"
    )

    parser.add_argument(
        "--python",
        type=Path,
        help="Python base directory; should have a `bin/python` executable.",
    )

    parser.add_argument("--pipenv", help="pipenv executable")
    parser.add_argument("--ctags", help="ctags executable")

    return parser


if __name__ == "__main__":
    main()
