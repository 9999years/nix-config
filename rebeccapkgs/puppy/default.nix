{ rustPlatform, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "puppy";
  version = "0.0.2";
  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "0pqsm76knybjfxcqx7z994j2909dma3qgr0a6ajagks51lxr8lhq";
  };
  cargoSha256 = "0g0bazfc5ncpgmf3fqs7bcqjkx7if3rlp08byl7n89gwg2zp6z5x";
}
