{ config, pkgs, lib, ... }:
let
  inherit (builtins) isList isString length head tail map;
  inherit (lib)
    any removeAttrs concatMapStringsSep optionals optionalString mapAttrs
    recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.langs;

  langs = mapAttrs (lang: value:
    let
      fst = head value;
      description = if isString fst then fst else null;
    in {
      inherit description;
      config = {
        environment.systemPackages =
          if description == null then value else tail value;
      };
    }) (with pkgs; {
      bash = [
        "support for writing Bash scripts"
        shellcheck
        nodePackages.bash-language-server # whyyyy do people keep writing infra in js
      ];

      c = [
        "support for compiling C programs"
        gcc
        gnumake
        (lowPriority clang)
        # llvmPackages.libclang
        (lowPriority clang-tools)
        (lowPriority clang-analyzer)
        autoconf
        automake
      ];

      coq = [ coq ];

      dhall = [ dhall dhall-bash dhall-json ];

      go = [ go ];

      java = [ openjdk ];

      nix = [
        rnix-lsp
        nixfmt
        nix-index # nix-index and nix-locate
        nix-top # what's building?
        nix-diff # why do derivations differ?
        nix-du # which gc roots take up space?
        nix-tree
        cachix
        any-nix-shell
      ];

      node = [ nodejs-12_x yarn ];

      perl = [ perl ];

      python = [
        ctags
        pipenv
        (highPriority (python38.withPackages (pyPkgs:
          with pyPkgs; [
            # Linters & devtools
            autopep8
            bandit
            black
            conda
            flake8
            hypothesis # property tests
            isort
            jedi
            mypy
            pep8
            ptpython # terminal
            pycodestyle
            pydocstyle
            pylama
            pylint
            pytest
            python-ctags3
            rope # refactoring library
            yapf

            # Utilities
            attrs
            beautifulsoup4
            grip
            pynvim
            pyyaml
            requests
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
    });

in {
  options.rebecca.langs = mkOption {
    type = types.listOf (types.enum attrNames langs);
    default = [ ];
    description = ''
      Programming languages to support development / compiling for.

      Possible values:
      <ul>
        <li>
    '' + (concatMapStringsSep "</li><li>" (lang:
      { description }: ''
        <code>${lang}</code>${
          optionalString (description != null) (" -- " + description)
        }
      '') langs) + ''
          </li>
        </ul>
      '';
  };

  config = mkMerge (map (lang: mkIf (any (l: l == lang) cfg) lang.config) cfg);
}
