{ stdenv, appimageTools, ... }: {
  installAppImage = { name, version, src, bin ? name
    , desktopFile ? "${bin}.desktop", buildInputs ? [ ], }:
    stdenv.mkDerivation rec {
      inherit name version src buildInputs;

      appImageName = "${name}-AppImage";

      extracted = appimageTools.extractType2 {
        name = appImageName;
        inherit src;
      };

      wrapped = appimageTools.wrapType2 {
        name = bin;
        inherit src;
      };

      srcs = [ wrapped extracted ];
      sourceRoot = ".";

      inherit desktopFile bin;

      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        # Copy the binary
        cp -r "$bin" "$out"

        # Copy the icons
        mkdir -p "$out/share"
        cp -r "$appImageName-extracted/usr/share" "$out/"

        # Copy the desktop file and patch it to have the right executable path
        mkdir -p "$out/share/applications"
        cp "$appImageName-extracted/$desktopFile" "$out/share/applications/"
        substituteInPlace "$out/share/applications/$desktopFile" \
                          --replace "Exec=AppRun" "Exec=$out/bin/$bin"
      '';
    };
}
