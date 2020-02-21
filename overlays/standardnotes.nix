self: super: {
  standardnotes = (let rebeccapkgs = import ../rebeccapkgs { pkgs = super; };
  in rebeccapkgs.appimage.installAppImage {
    inherit (super.standardnotes) name version src;
    bin = "standard-notes";
  }) // {
    inherit (super.standardnotes) pname meta;
  };
}

