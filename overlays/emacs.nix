self: super: {
  emacs = super.emacs.overrideAttrs (old: {
    # Prefer emacsclient.
    postInstall = (old.postInstall or "") + ''
      rm $out/share/applications/emacs.desktop
    '';
  });
}
