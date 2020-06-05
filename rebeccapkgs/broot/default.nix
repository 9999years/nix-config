{ stdenv, lib, rustPlatform, fetchCrate, libgit2, libiconv, darwin ? null }:
rustPlatform.buildRustPackage rec {
  pname = "broot";
  version = "0.13.6";

  buildInputs = [ libgit2 libiconv ]
    ++ (lib.optional stdenv.targetPlatform.isDarwin
      darwin.apple_sdk.frameworks.Security);

  src = fetchCrate {
    inherit version;
    crateName = pname;
    sha256 = "1s5dq1my3cpvr6khkfa84v9ydfy0p2jkdyhchwwrbgiph5ldvf4h";
  };

  cargoSha256 = "1cxvx51zkmhszmgwsi0aj469xz98v5nk79zvqfyma27gsnh8jczr";

  postInstall = ''
    fish_completions="$out/share/fish/vendor_completions.d/"
    mkdir -p $fish_completions
    find $releaseDir -name br.fish -o -name broot.fish -exec cp {} $fish_completions \;

    bash_completions="$out/etc/bash_completion.d/"
    mkdir -p $bash_completions
    find $releaseDir -name br.bash -o -name broot.bash -exec cp {} $bash_completions \;

    zsh_completions="$out/share/zsh/site-functions/"
    mkdir -p $zsh_completions
    find $releaseDir -name _br -o -name _broot -exec cp {} $zsh_completions \;

    mkdir -p $out/share/man/man1/
    # From release.sh
    sed -i "s/#version/$version/g" man/page
    sed -i "s/#date/$(date +'%Y\/%m\/%d')/g" man/page
    cp man/page $out/share/man/man1/broot.1

    fish_functions="$out/share/fish/vendor_functions.d/"
    mkdir -p $fish_functions
    $out/bin/broot --print-shell-function fish > $fish_functions/br.fish
  '';

  doCheck = false;
}
