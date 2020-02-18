self: super:
{
  cargo = super.cargo.override {
    shellHook = ''
      export PATH="$HOME/.cargo/bin:$PATH"
    '';
  };
}
