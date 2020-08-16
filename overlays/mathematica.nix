self: super: {
  mathematica = super.mathematica.overrideAttrs (old: rec {
    version = "12.1.1";
    name = "mathematica-${version}";

    src = super.requireFile rec {
      name = "Mathematica_${version}_LINUX.sh";
      sha256 =
        "ad47b886be4a9864d70f523f792615a051d4ebc987d9a0f654b645b4eb43b30a";
      url = "https://user.wolfram.com/portal/myProducts.html";
    };
  });
}
