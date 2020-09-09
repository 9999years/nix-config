{ stdenv, lib, fetchFromGitHub, python38 }@args:
import (fetchFromGitHub {
  owner = "9999years";
  repo = "spdx-tool";
  rev = "v1.0.3";
  sha256 = "1ybrmkamk6ii85j4dhs741pi5vc45flbk05c1w7yb6hpx22gqggp";
}) args
