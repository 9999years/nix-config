#!/usr/bin/env python3

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="build a NixOS qcow2 image; remaining arguments are passed to nix-build"
    )
    parser.add_argument(
        "base_file", type=Path, help="base Nix file to import; typically under ../hosts"
    )
    args, other_args = parser.parse_known_args()

    curdir = Path(__file__).parent

    with open(curdir / "qcow2.nix") as f:
        qcow2 = f.read().replace("./HOSTNAME.nix", str(args.base_file.resolve()))

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir = Path(tmpdir)
        qcow2_path = tmpdir / "qcow2.nix"
        with open(qcow2_path, "w") as f:
            f.write(qcow2)

        nix_build_args = [
            "nix-build",
            "<nixpkgs/nixos>",
            "--attr",
            "config.system.build.openstackImage",
            "-I",
            f"nixos-config={qcow2_path}",
        ] + other_args
        print("running:", " ".join(nix_build_args))
        proc = subprocess.run(nix_build_args, check=False,)
        if proc.returncode != 0:
            print("⚠️ nix-build failed")
            sys.exit(1)


if __name__ == "__main__":
    main()
