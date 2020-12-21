#! /usr/bin/env bash
source "$stdenv/setup"

dir="$out/share/icons/$theme/$size/$type/"
mkdir -p "$dir"
# ${src##*.} https://unix.stackexchange.com/a/236034
cp "$src" "$dir/$name.${src##*.}"
