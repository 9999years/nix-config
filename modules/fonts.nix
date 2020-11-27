{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.fonts;

in {
  options.rebecca.fonts = { enable = mkEnableOption "fonts"; };

  config = mkIf cfg.enable {
    fonts = {
      enableDefaultFonts = true;
      fontconfig.defaultFonts = {
        emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
        monospace =
          [ "PragmataPro Mono Liga" "Hack" "IBM Plex Mono" "Fira Mono" ];
      };
      fonts = with pkgs;
        [
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
    };

  };
}
