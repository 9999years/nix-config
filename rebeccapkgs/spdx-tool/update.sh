#! /usr/bin/env bash
set -e

echo "Fetching latest tag"
latest=$(git ls-remote --tags --sort=-version:refname \
  https://github.com/9999years/spdx-tool.git \
  | head -n1)
rev=$(echo "$latest" | cut -f1)
tag=$(echo "$latest" | cut -f2 | sed 's|refs/tags/||')

if grep --quiet "^ *rev *= *\"$rev\";" default.nix; then
  echo "Already up-to-date at tag $tag"
  exit
fi

old=$(mktemp)
cp default.nix "$old"
echo "Downloading new derivation"
curl -O https://raw.githubusercontent.com/9999years/spdx-tool/main/default.nix
echo "Determining sha256 of source"
drv=$(nix-shell -p nix-prefetch-github \
            --run "nix-prefetch-github --nix --rev \"$tag\" 9999years spdx-tool \
                      | tail -n +4 \
                      | sed 's/pkgs\.//; s/$/\\\\/g'")

echo "Patching 'src = ./.;' with 'src = fetchFromGitHub { ... };'"
sed --in-place "s|src *= *\./\.;|src = $drv;|" default.nix
diff "$old" default.nix
rm -f "$old"
