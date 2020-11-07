#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Optional


def main():
    args = Args.parse_args(argparser())
    coc_settings = CocSettings.from_root(args.root)

    new_coc_settings = {
        "python.formatting.autopep8Path": which("autopep8"),
        "python.formatting.blackPath": which("black"),
        "python.formatting.yapfPath": which("yapf"),
        "python.linting.flake8Path": which("flake8"),
        "python.linting.banditPath": which("bandit"),
        "python.linting.mypyPath": which("mypy"),
        "python.linting.pep8Path": which("pep8"),
        "python.linting.pydocstylePath": which("pydocstyle"),
        "python.linting.pylamaPath": which("pylama"),
        "python.linting.pylintPath": which("pylint"),
        "python.poetryPath": which("poetry"),
        "python.condaPath": which("conda"),
        "python.sortImports.path": which("isort"),
        "python.pythonPath": which("python"),
        "python.pipenvPath": which("pipenv"),
        "python.workspaceSymbols.ctagsPath": which("ctags"),
    }

    modified = coc_settings.update(new_coc_settings)

    if modified:
        coc_settings.maybe_backup()
        coc_settings.write()


@dataclass
class CocSettings:
    path: Path
    settings: Dict[str, object]

    @classmethod
    def from_root(cls, root: Optional[Path] = None) -> CocSettings:
        path = cls.find_path(root)
        return cls.from_path(path)

    @classmethod
    def from_path(cls, path: Path) -> CocSettings:
        if path.exists():
            with open(path) as coc_settings_file:
                settings = json.load(coc_settings_file)
        else:
            settings = {}

        return cls(path=path, settings=settings)

    @staticmethod
    def find_path(root: Optional[Path] = None) -> Path:
        if root is None:
            root = get_root_dir()

        vim_dir = root / ".vim"
        vim_dir.mkdir(parents=True, exist_ok=True)
        return vim_dir / "coc-settings.json"

    def maybe_backup(self) -> Optional[Path]:
        """Backup the settings if the file exists and return its new path.
        """
        if self.path.exists():
            path_backup = self.path.with_suffix(".json.bak")
            print("Saving old coc settings to", path_backup)
            return self.path.rename(path_backup)
        return None

    def write(self):
        with open(self.path, "w") as settings_file:
            json.dump(self.settings, settings_file, indent=True, sort_keys=True)

    def update(self, new_settings: Dict[str, Any]) -> bool:
        """Merge settings from ``new_settings`` into ``self``.

        Modifies ``self``, and returns ``True`` if any modifications were
        made.
        """
        modified = False
        for key, val in new_settings.items():
            if val is None:
                # Skip non-existent executables.
                continue

            old_val = self.settings.get(key, None)
            if old_val == val:
                continue

            if not modified:
                # Only print that we're updating the settings once.
                print("Updating settings in", self.path)
            modified = True

            if old_val is None:
                print("Setting", key, "to", val)
            else:
                print("Updating", key)
                print(" old:", old_val)
                print(" new:", val)

            if isinstance(val, Path):
                self.settings[key] = str(val)
            else:
                self.settings[key] = val

        return modified


def get_root_dir() -> Path:
    root = try_git_root()
    if root is not None:
        return root

    # Couldn't get the git root; try parents of the current dir.
    cwd = Path.cwd()
    for maybe_root in cwd.parents:
        vim_dir = maybe_root / ".vim"
        if vim_dir.exists():
            return maybe_root

    # No parents of the current dir already work; just use the
    # current dir.
    return cwd


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


def which(exe_name: str) -> Optional[str]:
    ret = shutil.which(exe_name)

    if ret is None:
        return None

    ret_p = Path(ret)
    if ret_p.is_symlink():
        raw_dest = os.readlink(ret_p)
        if raw_dest.startswith(os.environ.get("NIX_STORE", "/nix/store")):
            return raw_dest

    return ret


@dataclass
class Args:
    root: Optional[Path]

    @classmethod
    def parse_args(cls, parser: argparse.ArgumentParser) -> Args:
        args = parser.parse_args()
        return cls(root=args.root)


def argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Initializes a CoC environment for Python"
    )

    parser.add_argument(
        "--root",
        type=Path,
        help="""Root directory to find/update `.vim/coc-settings.json` in;
        assumed to be git repo root, parent directory with `.vim` directory, or
        current directory.""",
    )

    return parser


if __name__ == "__main__":
    main()
