{ pkgs ? import <nixpkgs> { }
  # nixos-unstable
, unstable ? import (fetchTarball
  "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz") { }
, ... }:
let
  lib = pkgs.lib;

  withPriority = p: drv: drv.overrideAttrs (old: { meta.priority = p; });
  lowPriority = withPriority "15";
  highPriority = withPriority "-1";
  becca = import ./rebeccapkgs { inherit pkgs; };

  sets = with pkgs; {
    gui = [
      alacritty # terminal
      firefox-bin
      lastpass-cli
      spotify # unfree
      discord # unfree
      typora # md editor (unfree)
      becca.fontbase
      becca.glimpse
      becca.amazing-marvin
      franz # chat tool
      gparted
      hfsprogs # macos file system support for gparted, etc.
      kdeApplications.spectacle # screenshot tool
      feh # photo viewer
      shotwell # photo viewer
      qalculate-gtk # calculator
      evince # pdf viewer
      qpdfview # pdf viewer with tabs
      becca.background-images
      psensor # view CPU usage / temps, etc.
      standardnotes
      calibre # ebook mgmt
      # libreoffice-fresh
      signal-desktop
    ];

    misc = [
      youtube-dl
      graphviz
      hyperfine
      units
      htop
      lynx
      becca.colortest
      unstable.pastel
      calc
    ];

    fonts = [
      stix-two # times-like
      hack-font # coding font
      gyre-fonts
      noto-fonts
      dejavu_fonts
      google-fonts
      terminus_font
      noto-fonts-cjk
      cantarell-fonts
      xorg.fontsunmisc
      wineWowPackages.fonts
      twitter-color-emoji
    ];

    git = [
      gitAndTools.gitFull # GPL v2
      git-lfs # MIT
      gitAndTools.hub # github hub, MIT
      gitAndTools.diff-so-fancy
      bfg-repo-cleaner
      tig # git text-gui
      # qtkeychain
    ];

    emacs = [
      emacs
      nixfmt # for nix-mode formatting
      ispell
      # rustc
      (lowPriority cargo)
      # rls
      unstable.rnix-lsp
      unstable.texlab
      ruby
      solargraph
      (python37.withPackages (pyPkgs:
        with pyPkgs; [
          python-language-server
          black
          grip
          mypy
          flake8
          pycodestyle
          pylint
        ]))
    ] ++ langs.clang ++ (with nodePackages; [
      vscode-css-languageserver-bin
      vscode-html-languageserver-bin
      # vscode-json-languageserver
      bash-language-server
      tern
      typescript
      typescript-language-server
    ]);

    vim = [
      neovim
      vim-vint # vimscript lint: https://github.com/Kuniwak/vint
    ];

    vscode = [
      # (vscode-with-extensions.override {
      # vscodeExtensions = [ vscode-extensions.matklad.rust-analyzer ];
      # })
      vscode
    ];

    hardware = [
      drm_info # display info
      pciutils # lspci
      lsof
    ];

    # Terminals, shells, and tty-related tools.
    terminals = [
      fish # GPL v2 & LGPL v2, OpenBSD License, ISC, NetBSD
      tmux # ISC License
      reptyr
    ];

    network = [
      bind # nslookup
      ncat
      (lowPriority inetutils) # whois
    ];

    files = [
      fd
      fzf # MIT
      # fselect # "Find files with SQL-like queries" https://github.com/jhspetersson/fselect
      tree
      sshfs-fuse # GPL v2
      lftp # GPL v3+
      ncdu # ncurses disk usage
      file
      dos2unix
      wget
      rsync
      (lowPriority binutils-unwrapped)
      nnn # File browser
      ranger # File browser
      up # Ultimate Plumber
      becca.mdv # markdown viewer
      mediainfo
      exiftool
      odt2txt
      watchman
      watchexec
      # archives
      zip
      unzip
      atool
      p7zip
    ];

    text = [
      silver-searcher
      exa
      just # github.com/casey/just
      # topgrade
      bat # https://github.com/sharkdp/bat
      # ruplacer
      ripgrep # rg, https://github.com/BurntSushi/ripgrep
      ripgrep-all # rga
      sd # Find-and-replacer, https://github.com/chmln/sd
      skim # Fuzzy finder, https://github.com/lotabout/skim
      toilet # command-line ascii art generator
      colordiff # GPL v3
      hexd
      tokei # Cloc, https://github.com/XAMPPRocky/tokei
      sourceHighlight # GPL v3
      fpp # Facebook PathPicker
      yank
      python37Packages.howdoi
      tldr
      becca.navi
    ];

    manipulation = [
      pandoc # GLP v2+
      pdftk
      poppler_utils # pdftotext
      mupdf # mutool
      (highPriority ghostscript)
      imagemagick7 # Derived Apache 2.0
      # bingrep # Binary introspection, https://github.com/m4b/bingrep
      xsv # CSV data manipulation and analysis tool, https://github.com/BurntSushi/xsv
      jq # MIT
      k2pdfopt
    ];

    math = [
      lean # theorem prover
    ];
  };

  langs = with pkgs; {
    agda = [ haskellPackages.Agda AgdaStdlib ];

    bash = [
      shellcheck
      nodePackages.bash-language-server # whyyyy do people keep writing infra in js
    ];

    clang = [
      gnumake
      clang
      # llvmPackages.libclang
      clang-tools
      clang-analyzer
      autoconf
      automake
    ];

    coq = [ coq ] ++ (with coqPackages; [ mathcomp interval equations corn ]);

    dhall = [ dhall dhall-bash dhall-json ];

    # gluon = [ becca.gluon ];

    go = [ go ];

    haskell = [ ghc cabal-install stack stylish-haskell hlint ]
      ++ (with haskellPackages; [
        happy
        pointfree
        apply-refact
        hspec
        hindent
        hdevtools
      ]) ++ (let
        all-hies = import
          (fetchTarball "https://github.com/infinisil/all-hies/tarball/master")
          { };
      in [ (all-hies.selection { selector = p: { inherit (p) ghc865; }; }) ]);

    java = [ openjdk ];

    nix = [
      nixfmt
      nix-index # nix-index and nix-locate
      cachix
      becca.nix-query
    ];

    node = [ nodejs-12_x ];

    perl = [ perl ]; # If nothing else, latexmk needs it.

    python = [
      (highPriority (python37.withPackages (pyPkgs:
        with pyPkgs; [
          # Linters, etc.
          black
          mypy
          flake8
          pycodestyle
          pylint
          ptpython
          pytest
          # Utilities
          grip
          pillow
          pyyaml
          pygments
          arrow
          atomicwrites
          attrs
          beautifulsoup4
          cached-property
          cachetools
          colorama
          more-itertools
          numpy
          pynvim
          dateutil
          # python-decouple
          requests
          termcolor
          toml
          unidecode
          urllib3
          wcwidth
        ])))
    ];

    ruby = [
      ruby # BDS 2-clause
      solargraph # ruby LSP
    ];

    rust = [
      rustup
      becca.rust-analyzer
      # rust-analyzer
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
      becca.latexdef
      (texlive.combine { inherit (texlive) scheme-medium latexmk; })
    ];
  };

  concatAttrLists = attrset: lib.concatLists (lib.attrValues attrset);
  removeAttrs = attrsToRemove: attrset:
    lib.filterAttrs (name: val: !(lib.elem name attrsToRemove)) attrset;
  keepAttrs = attrsToKeep: attrset:
    lib.filterAttrs (name: val: lib.elem name attrsToKeep) attrset;

  headAttrNames = [ "gui" ];

in rec {
  inherit sets;
  inherit langs;

  allLangs = concatAttrLists langs;

  headless = allLangs ++ (concatAttrLists (removeAttrs headAttrNames sets));
  all = headless ++ (concatAttrLists (keepAttrs headAttrNames sets));
}
