{ rustPlatform, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "puppy";
  version = "0.0.8";
  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "0dbr5phscr51l7appgma4s622s944fbmc3zsb21cn92rj015k2ii";
  };
  cargoSha256 = "1x9wzlykxl5lzvpsfg92ix9lw6spgzk3r30my3hlc4060vwnj8m3";
}
