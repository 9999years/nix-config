{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.nvim;

in {
  options.rebecca.nvim = { enable = mkEnableOption "neovim support"; };

  config = mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      (neovim.override {
        withNodeJs = true;
        vimAlias = true;
      })
      vim-vint # vimscript lint: https://github.com/Kuniwak/vint
    ]);
  };
}
