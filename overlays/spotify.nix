self: super: {
  spotify-scaled = {
    # High-DPI support: Spotify's --force-device-scale-factor argument; not added
    # if `null`, otherwise, should be a number.
    deviceScaleFactor ? null }:
    let inherit (super) spotify symlinkJoin makeWrapper lib;
    in symlinkJoin {
      name = "spotify-${spotify.version}";

      paths = [ spotify.out ];

      nativeBuildInputs = [ makeWrapper ];
      preferLocalBuild = true;
      passthru.unwrapped = spotify;
      postBuild = ''
        wrapProgram $out/bin/spotify \
            ${
              lib.optionalString (deviceScaleFactor != null) ''
                --add-flags ${
                  lib.escapeShellArg "--force-device-scale-factor=${
                    builtins.toString deviceScaleFactor
                  }"
                }
              ''
            }
      '';

      meta = spotify.meta // { priority = (spotify.meta.priority or 0) - 1; };
    };
}
