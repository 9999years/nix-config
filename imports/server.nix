# Configuration for desktops; graphical computers for personal use.
{ config, pkgs, lib, ... }:
let ssh-keys = import ./ssh-keys.nix;
in {
  imports = [
    <nixpkgs/nixos/modules/virtualisation/openstack-config.nix>
    ./common.nix
  ];

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  users = {
    mutableUsers = false;
    users = {
      root = {
        openssh.authorizedKeys.keys =
          [ ssh-keys.cervina-2020-08-19 ssh-keys.aquatica-2020-10-29 ];
      };
      becca = {
        openssh.authorizedKeys.keys =
          [ ssh-keys.cervina-2020-08-19 ssh-keys.aquatica-2020-10-29 ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  environment.noXlibs = true;
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
}
