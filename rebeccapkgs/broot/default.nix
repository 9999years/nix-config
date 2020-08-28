{ stdenv, lib, rustPlatform, fetchCrate, libgit2, libiconv, darwin ? null }:
let
  broot = rustPlatform.buildRustPackage rec {
    pname = "broot";
    version = "0.20.3";

    buildInputs = [ libgit2 libiconv ]
      ++ (lib.optional stdenv.targetPlatform.isDarwin
        darwin.apple_sdk.frameworks.Security);

    src = fetchCrate {
      inherit version;
      crateName = pname;
      sha256 = "0vw956c5xpjsbd9b0ardvgi9jjqb230m2x5n4h9ai0yiwizc8rh6";
    };

    cargoSha256 = "1zl4p3n327iq7nm7hi79zjxv2gvw9f3lwgkg1qp52kycv1af5gqp";

    postInstall = ''
      mkdir -p $out
      pushd $releaseDir \
      && find . -type f -maxdepth 1 -exec install -D {} "$out/target/{}" \; \
      && popd
      pushd $releaseDir/build/broot-* \
      && find build/broot-* -type f -exec install -D {} "$out/target/build/broot/{}" \; \
      && popd
      cp -r man $out/
    '';

    dontFixup = true;
    doCheck = false;
  };
in stdenv.mkDerivation rec {
  inherit (broot) pname version;

  src = broot;

  installPhase = ''
    mkdir -p $out
    cp -r bin/ $out/

    fish_completions="$out/share/fish/vendor_completions.d/"
    mkdir -p $fish_completions
    cp target/build/broot/out/{br.fish,broot.fish} $fish_completions

    fish_functions="$out/share/fish/vendor_functions.d/"
    mkdir -p $fish_functions
    $out/bin/broot --print-shell-function fish > $fish_functions/br.fish

    bash_completions="$out/etc/bash_completion.d/"
    mkdir -p $bash_completions
    cp target/build/broot/out/{br.bash,broot.bash} $bash_completions

    zsh_completions="$out/share/zsh/site-functions/"
    mkdir -p $zsh_completions
    cp target/build/broot/out/{_br,_broot} $zsh_completions

    mkdir -p $out/share/man/man1/
    # From release.sh
    sed -i "s/#version/$version/g" man/page
    sed -i "s/#date/$(date +'%Y\/%m\/%d')/g" man/page
    cp man/page $out/share/man/man1/broot.1
    ln -s broot.1 $out/share/man/man1/br.1
  '';
}
