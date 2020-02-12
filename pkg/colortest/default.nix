{ pkgs ? import <nixpkgs> {}, }:
with pkgs;
stdenv.mkDerivation rec {
  name = "colortest";
  version = "1.0.0";

  srcs = [
    (
      fetchFromGitHub {
        owner = "pablopunk";
        repo = "truecolor";
        name = "truecolor";
        rev = "2cc247ca4ad4915cc9788f74f7f46ecf0e26cf92";
        sha512 =
          "1941ns37d5ik79jsxxarybwav31jpc094lri04hxh5lwsd5f7y3912ml4jci0smi0x3rz26m40krfw5b79li8l5yq5g8n2hnzjyixld";
      }
    )
    (
      fetchFromGitHub {
        owner = "pablopunk";
        repo = "colortest";
        name = "colortest";
        rev = "e83efb1b01c2765cb210fa8ab00e61657653e0ea";
        sha512 =
          "0fkh80arfx5fzjfcx0na75khq42v68iqzybc4vxp93psrzz2fv26aqaln9nwrgq58i4jg2gfk96a8df3i36n34v2n1sgafjd5lasraa";
      }
    )
    (
      fetchzip {
        name = "color-tables";
        url = "https://gist.github.com/vivkin/567896630dbc588ad470b8196c601ad1/archive/f0fea2586ed3f2aa4785f48c09fdaa13ba4c06e1.zip";
        sha512 =
          "306g1z1gan17c00w1y1ha37ck58vbwdn29ry099297lxsmbk5kfha0pm932102y5369mwbycdai32qm27lj9ky4lvnxmh90w6k0y3ba";
      }
    )
  ];

  sourceRoot = ".";

  buildInputs = [
    # For truecolor:
    ncurses # tput
    ruby
  ];

  installPhase = ''
    mkdir -p $out/bin/
    cp colortest/colortest $out/bin/colortest
    cp color-tables/256-color-table.sh $out/bin/colortest-256
    cp color-tables/24-bit-color.sh $out/bin/colortest-24bit
    cp truecolor/truecolor $out/bin/colortest-truecolor
    chmod +x $out/bin/*
  '';
}
