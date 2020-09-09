{ stdenv, lib, fetchFromGitHub, python38, fzf }@args:
import (fetchFromGitHub {
  owner = "9999years";
  repo = "spdx-tool";
  rev = "v1.0.4";
  sha256 = "12qw5rq7zx2w03pj1n4axlg3gc6ywyyjm1slxrl7ivw387dn76m4";
}) args
