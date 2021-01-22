# Configuration for desktops; graphical computers for personal use.
{ config, pkgs, lib, ... }@args:
let
  inherit (lib) optional types mkEnableOption mkOption mkIf mkMerge;

  cfg = config.berry.server;

in {
  options.berry.server = { enable = mkEnableOption "server config"; };

  # TODO !!!!
  # See: /nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs/nixos/modules/virtualisation/openstack-config.nix
  # (mkIf cfg.enable
  # (import <nixpkgs/nixos/modules/virtualisation/openstack-config.nix> args))

  config = mkIf cfg.enable {
    systemd.services = {
      amazon-init.enable = false;
      apply-ec2-data.enable = false;
    };

    services.sshguard = { enable = true; };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    users.mutableUsers = false;

    networking.firewall.allowedTCPPorts = [ 22 80 443 ];

    system.autoUpgrade.allowReboot = true;

    environment.systemPackages = with pkgs; [
      htop
      gitAndTools.gitFull
      gitAndTools.hub
      gitAndTools.delta
      git-lfs
      (neovim.override {
        withNodeJs = true;
        vimAlias = true;
      })
      fish
      tmux
      bind
      ncat
      fd
      fzf
      file
      wget
      rsync
      watchman
      zip
      unzip
      atool
      broot
      exa
      just
      bat
      ripgrep
      hexd
      jq
      shellcheck
      gcc
      gnumake
      rnix-lsp
      nixfmt
      any-nix-shell
      nodejs-12_x
      yarn
      (python38.withPackages (pypkgs:
        with pypkgs; [
          (black.overridePythonAttrs { doCheck = false; })
          mypy
          ptpython
          pytest
          pynvim
          requests
        ]))
    ];
  };
}
