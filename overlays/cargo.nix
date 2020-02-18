self: super: {
  cargo = super.cargo.overrideAttrs (old: {
    shellHook = ''
      export PATH="$HOME/.cargo/bin:$PATH"
    '';
  });
}
