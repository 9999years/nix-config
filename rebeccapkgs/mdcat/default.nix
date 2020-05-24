{ rustPlatform, fetchCrate, openssl, pkg-config }:
rustPlatform.buildRustPackage rec {
  pname = "mdcat";
  version = "0.17.1";

  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "1yaqbia2fm3p76x5kjnplqc33h8x099krbiqmqgs9r0smsvj5g08";
  };

  cargoSha256 = "1pljgnckardy3j81im6k5dssz794c7vjx1dfr7950ndhrzwv7p22";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # DNS resolution failure in tests.
  doCheck = false;
}
