{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.git;

in {
  options.rebecca.git = { enable = mkEnableOption "Git development support"; };

  config = mkIf cfg.enable {
    # Credential managment
    services.gnome3.gnome-keyring.enable = lib.mkDefault true;

    environment.systemPackages = (with pkgs.gitAndTools; [
      gitFull
      hub # github hub
      gh # github cli https://cli.github.com/
      delta
    ]) ++ (with pkgs; [
      git-lfs
      bfg-repo-cleaner
      tig # git text-gui
    ]);
  };
}

