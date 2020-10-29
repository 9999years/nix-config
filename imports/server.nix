# Configuration for desktops; graphical computers for personal use.
{ config, pkgs, lib, ... }:
let ssh-keys = import ./ssh-keys.nix;
in {
  boot = {
    initrd.network.ssh.enable = lib.mkDefault true;
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    tmpOnTmpfs = lib.mkDefault true; # Keep /tmp in RAM
  };

  hardware.enableRedistributableFirmware = true;

  console.keyMap = "us";

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/New_York";

  users = {
    mutableUsers = false;
    users = {
      root = {
        openssh.authorizedKeys.keys =
          [ ssh-keys.cervina-2020-08-19 ssh-keys.aquatica-2020-10-29 ];
      };
      becca = {
        isNormalUser = true;
        description = "Rebecca Turner";
        extraGroups = [ "wheel" ];
        shell = pkgs.fish;
        uid = 1000;
        openssh.authorizedKeys.keys =
          [ ssh-keys.cervina-2020-08-19 ssh-keys.aquatica-2020-10-29 ];
      };
    };
  };

  environment.noXlibs = true;

  # Enable ssh in boot.
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  security.pam.enableSSHAgentAuth = true;
  services.openssh.enable = true;

  # networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.enable = false;

  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;
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
