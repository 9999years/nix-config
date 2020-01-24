{ pkgs, ... }:
with pkgs;
{
  gui = [
    alacritty
    firefox-bin
    lastpass-cli
    spotify  # unfree
    discord  # unfree
    feh
    typora
    (import ./pkg/fontbase { inherit pkgs; })
    (import ./pkg/glimpse { inherit pkgs; })
    franz
    kdeApplications.spectacle
    gparted
  ];

  git = [
    gitAndTools.gitFull  # GPL v2
    git-lfs  # MIT
    gitAndTools.hub  # github hub, MIT
    gitAndTools.diff-so-fancy
    bfg-repo-cleaner
    tig  # git text-gui
    # qtkeychain
  ];

  emacs = [
    ispell
    # TODO: tern from npm
  ];

  vim = [
    neovim
    vim-vint  # vimscript lint: https://github.com/Kuniwak/vint
  ];

  devtools = {
    # Terminals, shells, and tty-related tools.
    terminals = [
      fish  # GPL v2 & LGPL v2, OpenBSD License, ISC, NetBSD
      tmux  # ISC License
      reptyr
    ];

    network = [
      bind  # nslookup
      ncat
    ];

    files = [
      fd
      fzf  # MIT
      # fselect # "Find files with SQL-like queries" https://github.com/jhspetersson/fselect
      tree
      sshfs-fuse  # GPL v2
      lftp  # GPL v3+
      ncdu  # ncurses disk usage
      file
      dos2unix
      unzip
      wget
      rsync
      strings
    ];

    text = [
      silver-searcher
      exa
      just  # github.com/casey/just
      # topgrade
      bat  # https://github.com/sharkdp/bat
      # ruplacer
      ripgrep  # rg, https://github.com/BurntSushi/ripgrep
      ripgrep-all  # rga
      sd  # Find-and-replacer, https://github.com/chmln/sd
      skim  # Fuzzy finder, https://github.com/lotabout/skim
      toilet  # command-line ascii art generator
      colordiff  # GPL v3

      tokei # Cloc, https://github.com/XAMPPRocky/tokei
      sourceHighlight  # GPL v3
    ];

    misc = [
      shellcheck
      graphviz
      nix-index  # nix-index and nix-locate
      hyperfine
    ];

    manipulation = [
      pandoc  # GLP v2+
      pdftk
      ghostscript
      imagemagick7Big  # Derived Apache 2.0
      # bingrep # Binary introspection, https://github.com/m4b/bingrep
      xsv  # CSV data manipulation and analysis tool, https://github.com/BurntSushi/xsv
      jq   # MIT
    ];
  };

  hardware = [
    drm_info  # display info
    pciutils  # lspci
    lsof
  ];

  langs = {
    clang = [
      clang
      # llvmPackages.libclang
      clang-tools
      clang-analyzer
      autoconf
      automake
    ];

    dhall = [
      dhall
      dhall-bash
      dhall-json
    ];

    go = [ go ];

    haskell = [
      ghc
      cabal-install
      stack
      stylish-haskell
      hlint
      haskellPackages.happy
      haskellPackages.pointfree
      haskellPackages.apply-refact
      # haskellPackages.hie-core  # broken 2019-12-21
      haskellPackages.hspec
      haskellPackages.hindent
      haskellPackages.hdevtools
    ];

    java = [ openjdk ];

    node = [ nodejs-12_x ];

    perl = [ perl ];  # If nothing else, latexmk needs it.

    python = ([
      python38
      zlib  # For pip Pillow
    ] ++ (with python38Packages; [
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
    ]));

    ruby = [
      ruby  # BDS 2-clause
      solargraph  # ruby LSP
    ];

    rust = [
      rustup
      # cargo-deps # Generates a dep graph, https://github.com/m-cat/cargo-deps
      cargo-edit # https://github.com/killercup/cargo-edit
      cargo-update # https://github.com/nabijaczleweli/cargo-update
      cargo-watch # Watches source files, https://github.com/passcod/cargo-watch
      cargo-tree # Dep tree. https://github.com/sfackler/cargo-tree
      cargo-release # https://github.com/sunng87/cargo-release
      cargo-outdated # https://github.com/kbknapp/cargo-outdated
      cargo-make # https://github.com/sagiegurari/cargo-make
    ];

    tex = [
      (texlive.combined {inherit (texlive) scheme-medium latexmk;})
    ];
  };

  misc = [
    youtube-dl
  ];

  fonts = [
    stix-two
  ];
}
