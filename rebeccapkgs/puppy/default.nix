{ rustPlatform, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "puppy";
  version = "0.0.5";
  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "0kxkp40386c13f461mdlm0kkdqnbnw0ik28yww5m8k2axry1lfix";
  };
  cargoSha256 = "05zgappvkflskq02l2w8wncrvj7r8bq0nmp7yl9l0dcrigw29s5b";
}
