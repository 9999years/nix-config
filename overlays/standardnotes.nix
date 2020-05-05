self: super: {
  standardnotes = (self.rebecca.appimage.installAppImage {
    inherit (super.standardnotes) name version src;
    bin = "standard-notes";
  }) // {
    inherit (super.standardnotes) pname meta;
  };
}

