{ emacs ? (import <nixpkgs> { }).emacs, }:
emacs.overrideAttrs (attrs: {
  # Prefer # emacsclient.
  postInstall = (attrs.postInstall or "") + ''
    rm $out/share/applications/emacs.desktop
  '';
})
