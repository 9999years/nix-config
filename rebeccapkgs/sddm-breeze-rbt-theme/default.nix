{ stdenvNoCC, lib, plasma5, background-images, ... }:
# background image path
let
  inherit (plasma5) plasma-workspace;
  drv = { background ? "${background-images}/share/wallpapers/night-stars.jpg"
      # font size
    , fontSize ? 10,
    # theme color
    color ? "#1d99f3", ... }:
    stdenvNoCC.mkDerivation {
      name = "sddm-breeze-rbt-theme";
      version = "1.0.0";

      meta = {
        description = ''
          A variant of the SDDM Breeze theme provided by KDE 5 Plasma using a
          prettier background image.
        '';
      };

      srcs = [ ./theme.conf plasma-workspace.src ];
      sourceRoot = ".";
      unpackPhase = ''
        for src in $srcs
        do
          case "$src" in
            *.tar.xz)
              tar -xf "$src"
              ;;

            *)
              cp "$src" "$(stripHash "$src")"
              ;;
          esac
        done
      '';

      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/share/sddm/themes/

        cp -r ${plasma-workspace.name}/sddm-theme breeze-rbt
        rm -r breeze-rbt/dummydata
        rm breeze-rbt/theme.conf.cmake

        link_dest="$(readlink ${plasma-workspace.name}/sddm-theme/components)"
        rm breeze-rbt/components
        cp -r "${plasma-workspace.name}/sddm-theme/$link_dest" breeze-rbt/components
        rm breeze-rbt/components/artwork/README.txt

        substitute theme.conf breeze-rbt/theme.conf \
                   --subst-var-by color "${color}" \
                   --subst-var-by fontSize ${toString fontSize} \
                   --subst-var-by background "${background}"
        mv breeze-rbt $out/share/sddm/themes/
      '';
    };
in lib.makeOverridable drv { }
