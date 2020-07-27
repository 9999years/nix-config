{ pkgs ? import <nixpkgs> { }, ... }:
let
  inherit (pkgs) lib rebecca unstable;

  withPriority = p: drv: drv.overrideAttrs (old: { meta.priority = p; });
  lowPriority = withPriority "15";
  highPriority = withPriority "-1";

  sets = with pkgs; {
    gui = [
      alacritty # terminal
      firefox-bin
      lastpass-cli
      spotify # unfree
      discord # unfree
      # unstable.typora # md editor (unfree)
      rebecca.glimpse
      inkscape
      gparted
      dosfstools # for fat/fat32 filesystems
      mtools # for fat/fat32 filesystems
      hfsprogs # macos file system support for gparted, etc.
      kdeApplications.spectacle # screenshot tool
      feh # photo viewer
      qalculate-gtk # calculator
      evince # pdf viewer
      qpdfview # pdf viewer with tabs
      rebecca.background-images
      psensor # view CPU usage / temps, etc.
      # standardnotes # may need to be from unstable
      calibre # ebook mgmt
      # libreoffice-fresh
      signal-desktop
      unstable.todoist-electron
    ];

    misc = [
      patchelf
      youtube-dl
      graphviz
      hyperfine
      units
      htop
      rebecca.colortest
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
      nixpkgs.gitAndTools.delta
      bfg-repo-cleaner
      tig # git text-gui
      # qtkeychain
    ];

    vim = [
      neovim
      vim-vint # vimscript lint: https://github.com/Kuniwak/vint
    ] ++ (with nodePackages; [
      vscode-css-languageserver-bin
      vscode-html-languageserver-bin
      # vscode-json-languageserver
      bash-language-server
      # tern
      # typescript
      # typescript-language-server
    ]);

    vscode = [
      # (unstable.vscode-with-extensions.override {
      # vscodeExtensions = with unstable.vscode-extensions;
      # [
      # # ms-vscode.cpptools
      # # llvm-org.lldb-vscode
      # matklad.rust-analyzer
      # ];
      # })
      unstable.vscode
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
      ranger # File browser
      up # Ultimate Plumber
      mediainfo
      exiftool
      odt2txt
      watchman
      watchexec
      # archives
      zip
      unzip
      atool
      rebecca.broot
    ];

    text = [
      silver-searcher
      exa
      just # github.com/casey/just
      # topgrade
      bat # https://github.com/sharkdp/bat
      # ruplacer
      ripgrep # rg, https://github.com/BurntSushi/ripgrep
      # ripgrep-all # rga
      # sd # Find-and-replacer, https://github.com/chmln/sd
      skim # Fuzzy finder, https://github.com/lotabout/skim
      # toilet # command-line ascii art generator
      colordiff # GPL v3
      hexd
      tokei # Cloc, https://github.com/XAMPPRocky/tokei
      sourceHighlight # GPL v3
      fpp # Facebook PathPicker
      yank
      # python37Packages.howdoi
      # tldr
      # rebecca.navi
      rebecca.mdcat
    ];

    manipulation = [
      pandoc # GLP v2+
      pdftk
      poppler_utils # pdftotext
      mupdf # mutool
      k2pdfopt
      (highPriority ghostscript)
      imagemagick7 # Derived Apache 2.0
      # bingrep # Binary introspection, https://github.com/m4b/bingrep
      # xsv # CSV data manipulation and analysis tool, https://github.com/BurntSushi/xsv
      jq # MIT
    ];

    math = [
      # lean # theorem prover
      # mathematica
    ];
  };

  langs = with pkgs; {
    # agda = [ haskellPackages.Agda AgdaStdlib ];

    bash = [
      shellcheck
      nodePackages.bash-language-server # whyyyy do people keep writing infra in js
    ];

    clang = [
      gcc
      gnumake
      clang
      # llvmPackages.libclang
      clang-tools
      clang-analyzer
      autoconf
      automake
    ];

    # coq = [ coq ] ++ (with coqPackages; [ mathcomp interval equations corn ]);

    # dhall = [ dhall dhall-bash dhall-json ];

    # gluon = [ rebecca.gluon ];

    # go = [ go ];

    java = [ openjdk ];

    nix = [
      unstable.rnix-lsp
      nixfmt
      nix-index # nix-index and nix-locate
      cachix
      rebecca.nix-query
    ];

    node = [ nodejs-12_x ];

    # perl = [ perl ];

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
          attrs
          beautifulsoup4
          cached-property
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

    rust = [
      rustup
      # rebecca.rust-analyzer
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
      rebecca.latexdef
      unstable.texlab
      (texlive.combine { inherit (texlive) scheme-small latexmk; })
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
