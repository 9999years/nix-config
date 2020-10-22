{ pkgs ? import <nixpkgs> { }, ... }:
let
  inherit (pkgs) lib rebecca;

  withPriority = p: drv: drv.overrideAttrs (old: { meta.priority = p; });
  lowPriority = withPriority "15";
  highPriority = withPriority "-1";

  sets = with pkgs; {
    gui = [
      alacritty # terminal
      kitty # terminal
      firefox-bin
      lastpass-cli
      (spotify.override { deviceScaleFactor = 1.66; }) # unfree
      discord # unfree
      # typora # md editor (unfree)
      # rebecca.glimpse
      gimp # admitting defeat
      pinta # paint tool
      inkscape
      gparted
      dosfstools # for fat/fat32 filesystems
      mtools # for fat/fat32 filesystems
      hfsprogs # macos file system support for gparted, etc.
      kdeApplications.spectacle # screenshot tool
      gnome3.eog # photo viewer
      qalculate-gtk # calculator
      evince # pdf viewer
      qpdfview # pdf viewer with tabs
      rebecca.background-images
      psensor # view CPU usage / temps, etc.
      # standardnotes
      calibre # ebook mgmt
      # libreoffice-fresh
      signal-desktop
      todoist-electron
      xclip
    ];

    misc = [
      patchelf
      youtube-dl
      graphviz
      hyperfine
      units
      htop
      bottom
      rebecca.colortest
      calc
      rebecca.puppy
      rebecca.spdx-tool
      (aspellWithDicts (dicts:
        with dicts; [
          en
          en-computers
          # en-science
        ]))
      hunspellDicts.en-us-large
      manpages
      posix_man_pages
      libcap_manpages
      fontconfig.out # gives us fonts.dtd
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
      jetbrains-mono # https://www.jetbrains.com/lp/mono/
    ] ++ (with rebecca.typefaces; [
      atkinson-hyperlegible-font # https://www.brailleinstitute.org/freefont
      velvetyne
      dotcolon
      bagnard
      cotham
      gap-sans
      inter
      juniusX
      nimbus-sans-l
      office-code-pro
      routed-gothic
      dse-typewriter
      din-1451
      tgl-0-16
      ms-33558
    ]);

    git = (with gitAndTools; [
      gitFull # GPL v2
      hub # github hub, MIT
      gh # github cli https://cli.github.com/
      diff-so-fancy
      delta
    ]) ++ [
      git-lfs # MIT
      bfg-repo-cleaner
      tig # git text-gui
      # qtkeychain
    ];

    vim = [
      (neovim.override {
        withNodeJs = true;
        vimAlias = true;
      })
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
      # (vscode-with-extensions.override {
      # vscodeExtensions = with vscode-extensions;
      # [
      # # ms-vscode.cpptools
      # # llvm-org.lldb-vscode
      # matklad.rust-analyzer
      # ];
      # })
      vscode
    ];

    hardware = [
      drm_info # display info
      pciutils # lspci
      hwinfo
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
      devd # static file server
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
      broot
      gnome3.librsvg
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
      (lowPriority clang)
      # llvmPackages.libclang
      (lowPriority clang-tools)
      (lowPriority clang-analyzer)
      autoconf
      automake
    ];

    # coq = [ coq ] ++ (with coqPackages; [ mathcomp interval equations corn ]);

    # dhall = [ dhall dhall-bash dhall-json ];

    # gluon = [ rebecca.gluon ];

    # go = [ go ];

    # java = [ openjdk ];

    nix = [
      rnix-lsp
      nixfmt
      nix-index # nix-index and nix-locate
      nix-top # what's building?
      nix-diff # why do derivations differ?
      nix-du # which gc roots take up space?
      nix-tree
      cachix
      rebecca.nix-query
      any-nix-shell
    ];

    node = [ nodejs-12_x ];

    perl = [ perl ]; # needed for fish fzf plugin!

    python = [
      (highPriority (python38.withPackages (pyPkgs:
        with pyPkgs; [
          # Linters, etc.
          (black.overridePythonAttrs { doCheck = false; })
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
      cargo-generate # https://github.com/ashleygwilliams/cargo-generate
      cargo-edit # https://github.com/killercup/cargo-edit
      cargo-update # https://github.com/nabijaczleweli/cargo-update
      cargo-watch # Watches source files, https://github.com/passcod/cargo-watch
      cargo-release # https://github.com/sunng87/cargo-release
      cargo-outdated # https://github.com/kbknapp/cargo-outdated
      cargo-make # https://github.com/sagiegurari/cargo-make
    ];

    tex = [
      rebecca.latexdef
      texlab
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
