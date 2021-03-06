{ stdenv, lib, symlinkJoin, google-chrome, makeDesktopItem }:

{
# Base URL
url

# Derivation name; if non-null, used for `desktopItem.name`,
# `desktopItem.icon`, and each icon in `icons`.
, name ? null

  # Icons to install. A list of attrsets, each of which should contain:
  #   - size
  #   - file (or a derivation)
  #   - theme (otherwise, "hicolor" is assumed)
  #   - type (otherwise, "app" is assumed)
, icons ? [ ]

  # Arguments passed directly to `makeDesktopItem`
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/make-desktopitem/default.nix
  # Should probably include:
  #   - desktopName (application name, user-visible string)
  #   - name (file name, less-visible, no spaces)
  #   - comment (tooltip)
  #   - icon
  #     See: https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html
  #   - categories (semicolon-separated)
  #     See: https://specifications.freedesktop.org/menu-spec/latest/apa.html
  #          https://specifications.freedesktop.org/menu-spec/latest/apas02.html
, desktopItem }:

let
  outerName = name;

  item = makeDesktopItem ({
    exec = ''${google-chrome}/bin/google-chrome-stable "--app=${url}"'';
  } // lib.optionalAttrs (name != null) {
    inherit name;
    icon = name;
  } // desktopItem);

  writeIcon = attrs@{ size # Icon size, like "64x64" or "scalable"
    , name # Icon name
    , src # Input file
    , theme ? "hicolor" # Icon theme name
    , type ? "apps" # Icon type
    }:
    stdenv.mkDerivation {
      inherit name src size theme type;
      builder = ./icon-builder.sh;
    };

  iconsWithName =
    if name != null then map (icon: { inherit name; } // icon) icons else icons;

in symlinkJoin ({
  paths = [ item ] ++ map writeIcon iconsWithName;
} // (if name != null then {
  inherit name;
} else {
  inherit (desktopItem) name;
}))
