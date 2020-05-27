{ lib, rustPlatform, fetchFromGitHub, ... }:
rustPlatform.buildRustPackage rec {
  pname = "nix-query";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "nix-query";
    rev = "v${version}";
    sha512 =
      "0pyl7h560g0kk3cf2866pznbghrg0n7n7l3ljnjac16chbldwy7whsjnv0ac13gi64k1213fhh3s92mykbwmdr6m3jqf38d83x4h5ni";
  };

  cargoSha256 = "1cwcncprh52qs50mg568ym6s6cv422bgjssjcyb1k2drgprr6l2s";

  meta = with lib; {
    description = "A cached Nix package fuzzy-search.";
    license = with licenses; [ agpl3 ];
    maintainers = with maintainers; [ ];
  };
}
