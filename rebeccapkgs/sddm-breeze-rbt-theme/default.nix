{ stdenv, lib, plasma-workspace, background-images, ... }:
# background image path
let
  drv = { background ? "${background-images}/share/wallpapers/night-stars.jpg"
      # font size
    , fontSize ? 10,
    # theme color
    color ? "#1d99f3", ... }:
    stdenv.mkDerivation {
      name = "sddm-breeze-rbt-theme";
      version = "1.0.0";

      meta = {
        description = ''
          A variant of the SDDM Breeze theme provided by KDE 5 Plasma using a
          prettier background image.
        '';
      };

      src = ./theme.conf;
      dontUnpack = true;

      buildInputs = [ plasma-workspace ];

      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/share/sddm/themes/
        cd $out/share/sddm/themes/
        cp -r ${plasma-workspace}/share/sddm/themes/breeze breeze-rbt
        substitute $src breeze-rbt/theme.conf \
                   --subst-var-by color "${color}" \
                   --subst-var-by fontSize ${toString fontSize} \
                   --subst-var-by background "${background}"
        cat breeze-rbt/theme.conf
      '';
    };
in lib.makeOverridable drv { }
