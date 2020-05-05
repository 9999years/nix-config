self: super: {
  mathematica = super.mathematica.overrideAttrs (old: rec {
    version = "12.1.0";
    name = "mathematica-${version}";

    src = super.requireFile rec {
      name = "Mathematica_${version}_LINUX.sh";
      sha256 = "15m9l20jvkxh5w6mbp81ys7mx2lx5j8acw5gz0il89lklclgb8z7";
      url = "https://user.wolfram.com/portal/myProducts.html";
    };
  });
}
