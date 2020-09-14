self: super: {
  ghostwriter = super.ghostwriter.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ self.hunspellDicts.en-us-large ];
  });
}
