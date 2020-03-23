{
  cargo = import ./cargo.nix;
  emacs = import ./emacs.nix;
  nvim = import ./nvim.nix;
  standardnotes = import ./standardnotes.nix;
  vscode-rust-analyzer = import ./vscode-rust-analyzer.nix { };
}
