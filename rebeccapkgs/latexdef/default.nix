{ lib, rustPlatform, fetchFromGitHub, ... }:
rustPlatform.buildRustPackage rec {
  pname = "latexdef";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "latexdef";
    rev = "v${version}";
    sha512 =
      "2vaq93grwhs0vpbx344mcza8jqzvf3d3171laskijjv60mi8vpfpy6lm2wqnjf7b7hcqqy65zkynwkx5ipr0djggmv4qii5rd0hrly1";
  };

  cargoSha256 = "1ln1nz3lsm8braypjzl2h0xj1409azdpxwmsy758i1m7vi209z8w";

  meta = with lib; {
    description =
      "A command-line tool to show the definitions of LaTeX commands.";
    license = with licenses; [ agpl3 ];
    maintainers = with maintainers; [ ];
  };
}
