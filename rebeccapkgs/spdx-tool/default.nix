{ stdenv, lib, fetchFromGitHub, python38 }@args:
import (fetchFromGitHub {
  owner = "9999years";
  repo = "spdx-tool";
  rev = "v1.0.2";
  sha256 = "16fwvzpqa3g62f0ba4lb181jhazj2svkwnf7khp33x1wpvc9kd8c";
}) args
