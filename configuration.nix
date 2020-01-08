# man 5 configuration.nix
# nixos-help
{ config, pkgs, ... }:

let
  wifi-passwords = import ./wifi-passwords.nix {};

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "aquatica"; # Define your hostname.
  # networking.networkmanager.enable = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.networks = {
    trouse = {
      psk = wifi-passwords.trouse;
    };
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s1.useDHCP = true;
  networking.interfaces.enp5s0.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    alacritty
    emacs
    i3

    python38

    gitAndTools.gitFull  # GPL v2
    git-lfs  # MIT
    gitAndTools.hub  # github hub, MIT
    gitAndTools.diff-so-fancy
    bfg-repo-cleaner

    fish  # GPL v2 & LGPL v2, OpenBSD License, ISC, NetBSD
    neovim
    tmux  # ISC License

    silver-searcher
    fzf  # MIT
    jq  # MIT
    exa
    just  # github.com/casey/just
    # topgrade
    bat  # https://github.com/sharkdp/bat
    # bingrep # Binary introspection, https://github.com/m4b/bingrep
    # fselect # "Find files with SQL-like queries" https://github.com/jhspetersson/fselect
    hyperfine
    # ruplacer
    ripgrep  # rg, https://github.com/BurntSushi/ripgrep
    ripgrep-all
    sd # Find-and-replacer, https://github.com/chmln/sd
    skim # Fuzzy finder, https://github.com/lotabout/skim
    tokei # Cloc, https://github.com/XAMPPRocky/tokei
    xsv # CSV data manipulation and analysis tool, https://github.com/BurntSushi/xsv

    rustup
    # cargo-deps # Generates a dep graph, https://github.com/m-cat/cargo-deps
    cargo-edit # https://github.com/killercup/cargo-edit
    cargo-update # https://github.com/nabijaczleweli/cargo-update
    cargo-watch # Watches source files, https://github.com/passcod/cargo-watch
    cargo-tree # Dep tree. https://github.com/sfackler/cargo-tree
    cargo-release # https://github.com/sunng87/cargo-release
    cargo-outdated # https://github.com/kbknapp/cargo-outdated
    cargo-make # https://github.com/sagiegurari/cargo-make

    stylish-haskell
    hlint
    haskellPackages.happy
    haskellPackages.pointfree
    haskellPackages.apply-refact
    # haskellPackages.hie-core  # broken 2019-12-21
    haskellPackages.hspec
    haskellPackages.hindent
    haskellPackages.hdevtools

    solargraph  # ruby LSP
    vim-vint  # vimscript lint: https://github.com/Kuniwak/vint
    youtube-dl
    sshfs-fuse  # GPL v2
    lftp  # GPL v3+
    pandoc  # GLP v2+ & BSD 3-clause & MIT & WTFPL (dzslides)
    colordiff  # GPL v3
    sourceHighlight  # GPL v3

    clang
    # llvmPackages.libclang
    clang-tools
    clang-analyzer

    ruby  # BDS 2-clause
    openjdk
    shellcheck
    ghostscript
    imagemagick7Big  # Derived Apache 2.0
    graphviz
    toilet  # command-line ascii art generator
    reptyr
    tig  # git text-gui
    ghc
    cabal-install
    stack
    go
    pdftk
    perl  # If nothing else, latexmk needs it.

    alacritty
    fd
    nodejs-12_x
    tree

    dhall
    dhall-bash
    dhall-json

    zlib  # For pip Pillow

    firefox
    spotify
    lastpass-cli
    discord

    drm_info  # display info
    mdadm  # RAID drives
    nix-index  # nix-index and nix-locate
    pciutils  # lspci
  ] ++ (with pkgs; with python38Packages; [
    # Linters, etc.
    # pip
    # setuptools
    # virtualenv
    # pytest
    # black
    # grip
    # mypy
    # flake8
    # ptpython
    # pycodestyle
    # pylint
    # # Utilities
    # pillow
    # pyyaml
    # pygments
    # arrow
    # atomicwrites
    # attrs
    # beautifulsoup4
    # cached-property
    # cachetools
    # colorama
    # more-itertools
    # numpy
    # pynvim
    # dateutil
    # python-decouple
    # requests
    # termcolor
    # toml
    # unidecode
    # urllib3
    # wcwidth
  ]);

  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  # services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.pathsToLink = [ "/libexec" ];
  services.xserver = {
    enable = true;
    dpi = 144;

    desktopManager = {
      default = "xfce";
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

    windowManager.i3 = {
      package = pkgs.i3-gaps;
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        # i3blocks
        i3lock
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.becca = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # Passwordless sudo
  security.sudo.extraConfig = ''
    %wheel ALL=(ALL:ALL) NOPASSWD: ALL
    '';

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

