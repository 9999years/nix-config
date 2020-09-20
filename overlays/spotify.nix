self: super: {
  # Add `--force-device-scale-factor=1.66` to Spotify.
  spotify = super.spotify.overrideAttrs (old: rec {
    # $librarypath is made from a local variable in the spotify derivation; if
    # it goes away, this won't work.
    # see: nixpkgs/pkgs/applications/audio/spotify/default.nix
    installPhase = old.installPhase + ''
      if [[ -z "$librarypath" ]]; then
        echo "\$librarypath var isn't set; spotify overlay is invalid"
        exit 1
      fi

      # Undo the first wrapProgram call
      mv $out/share/spotify/.spotify-wrapped $out/share/spotify/spotify
      # Repeat it, adding --force-device-scale-factor
      wrapProgram $out/share/spotify/spotify \
        --prefix LD_LIBRARY_PATH : "$librarypath" \
        --prefix PATH : "${super.gnome3.zenity}/bin" \
        --add-flags "--force-device-scale-factor=1.66"
    '';
  });
}
