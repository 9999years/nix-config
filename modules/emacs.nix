{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.emacs;

in {
  options.berry.emacs = { enable = mkEnableOption "Emacs text editor"; };

  config = mkIf cfg.enable {
    services.emacs = {
      enable = true;
      defaultEditor = true;
    };
  };
}
