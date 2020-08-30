{ rustPlatform, fetchCrate }:
rustPlatform.buildRustPackage rec {
  pname = "puppy";
  version = "0.0.3";
  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "13py8mc10ggzn6y55vrfc31fq9kw1xzsqa9757cbvjxnrm257gh0";
  };
  cargoSha256 = "13zj0d0ssf7w9d7vxnrnsmvy6v3i4w1rh1wizjyrsnmhqf8596bv";
}
