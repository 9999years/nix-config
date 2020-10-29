#!/usr/bin/env python3

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="build a NixOS iso; remaining arguments are passed to nix-build"
    )
    parser.add_argument(
        "base_file", type=Path, help="base Nix file to import; typically under ../hosts"
    )
    args, other_args = parser.parse_known_args()

    curdir = Path(__file__).parent

    with open(curdir / "iso.nix") as f:
        iso = f.read().replace("./HOSTNAME.nix", str(args.base_file.resolve()))

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        iso_path = tmpdir / "iso.nix"
        with open(iso_path, "w") as f:
            f.write(iso)

        nix_build_args = [
            "nix-build",
            "<nixpkgs/nixos>",
            "--attr",
            "config.system.build.isoImage",
            "-I",
            f"nixos-config={iso_path}",
        ] + other_args
        print("running:", " ".join(nix_build_args))
        proc = subprocess.run(nix_build_args, check=False,)
        if proc.returncode != 0:
            print("⚠️ nix-build failed")
            sys.exit(1)


if __name__ == "__main__":
    main()
