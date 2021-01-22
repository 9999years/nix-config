{ pkgs ? import <nixpkgs> { } }:

# See ../modules/xserver-packages.nix for GUI programs.
# See ../modules/fonts.nix for fonts.

let
  inherit (pkgs) rebecca; # ../rebeccapkgs

  withPriority = p: drv: drv.overrideAttrs (old: { meta.priority = p; });
  lowPriority = withPriority "15";
  highPriority = withPriority "-1";

  pythonWithPkgs = pkgs.python38.withPackages (pypkgs:
    with pypkgs; [
      autopep8
      bandit
      black
      flake8
      hypothesis
      isort
      jedi
      mypy
      pep8
      ptpython
      pydocstyle
      pylama
      pylint
      pynvim
      pytest
      python-ctags3
      requests
      rope
      yapf
    ]);

  corePkgs = with pkgs;
    [
      htop
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
      pythonWithPkgs
      chezmoi # dotfiles manager
    ] ++ (with pkgs.gitAndTools; [ gitFull hub delta ]);

  allPkgs = with pkgs;
    corePkgs

    ++ [
      # Bash
      shellcheck
      nodePackages.bash-language-server

      # C compilers / tools
      gcc
      gnumake
      (lowPriority clang)
      # llvmPackages.libclang
      (lowPriority clang-tools)
      (lowPriority clang-analyzer)
      autoconf
      automake

      # Nix
      rnix-lsp
      nixfmt
      any-nix-shell
      nix-index # nix-index and nix-locate
      nix-top # what's building?
      nix-diff # why do derivations differ?
      nix-tree
      any-nix-shell

      # Node
      nodejs-12_x
      yarn

      # Web dev
      nodePackages.vscode-css-languageserver-bin
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-json-languageserver
      nodePackages.typescript-language-server

      # Perl
      perl

      # Python
      ctags
      pythonWithPkgs

      # Misc
      patchelf
      youtube-dl
      graphviz
      hyperfine
      units
      htop
      bottom
      rebecca.colortest
      calc
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
      drm_info # display info
      pciutils # lspci
      hwinfo
      lsof
      fish
      tmux
      reptyr
      bind # nslookup
      ncat
      (lowPriority inetutils) # whois
      devd # static file server
      fd
      fzf
      # fselect # "Find files with SQL-like queries" https://github.com/jhspetersson/fselect
      tree
      sshfs-fuse
      lftp
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
      hexd
      tokei # Cloc, https://github.com/XAMPPRocky/tokei
      sourceHighlight
      fpp # Facebook PathPicker
      yank
      # python37Packages.howdoi
      # tldr
      # rebecca.navi
      rebecca.mdcat
      pandoc
      pdftk
      rebecca.pagelabels
      poppler_utils # pdftotext
      # mupdf # mutool; marked insecure
      # k2pdfopt # depends on insecure mupdf :(
      (highPriority ghostscript)
      imagemagick7
      # bingrep # Binary introspection, https://github.com/m4b/bingrep
      # xsv # CSV data manipulation and analysis tool, https://github.com/BurntSushi/xsv
      jq # MIT
      dosfstools # fat/fat32 support
      mtools # fat/fat32 support
      hfsprogs # MacOS/APFS support
    ]

    # Git
    ++ (with gitAndTools;
      [
        gh # github cli https://cli.github.com/
      ]) ++ [
        git-lfs
        bfg-repo-cleaner
        tig # git text-gui

        # Vim
        (neovim.override {
          withNodeJs = true;
          vimAlias = true;
        })
        vim-vint # vimscript lint: https://github.com/Kuniwak/vint

        # Rust
        rustup
        rust-analyzer
        # cargo-deps # Generates a dep graph, https://github.com/m-cat/cargo-deps
        cargo-generate # https://github.com/ashleygwilliams/cargo-generate
        cargo-edit # https://github.com/killercup/cargo-edit
        cargo-update # https://github.com/nabijaczleweli/cargo-update
        cargo-watch # Watches source files, https://github.com/passcod/cargo-watch
        cargo-release # https://github.com/sunng87/cargo-release
        cargo-outdated # https://github.com/kbknapp/cargo-outdated
        cargo-make # https://github.com/sagiegurari/cargo-make

        # LaTeX
        rebecca.latexdef
        texlab
      ];

in {
  core = corePkgs;
  all = allPkgs;
}
