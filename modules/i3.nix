{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.i3;

  berrypkgs = import ../berrypkgs { inherit pkgs; };
  background =
    "${berrypkgs.background-images}/share/wallpapers/night-stars.jpg";

in {
  options.berry.i3 = { enable = mkEnableOption "i3 display manager"; };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = lib.mkDefault true;
      dpi = lib.mkDefault 175;

      libinput = {
        enable = true;
        naturalScrolling = true; # Windows-style, baby!
      };

      displayManager = {
        lightdm.background = background;
        # Automatic login
        auto.enable = true;
        auto.user = "berry";
      };

      desktopManager = rec {
        default = "xfce";
        wallpaper = {
          mode = "fill";
          combineScreens = false;
        };
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
          # NixOS incorrectly guesses that xfce (or maybe xfwm...?) can handle setting
          # the background. It cannot -- at least not when we're using it like this,
          # so we have to patch the script back in. It just uses feh to set the background.
          # https://github.com/NixOS/nixpkgs/blob/ae1cb0bdf98a325062eb9c5bd6af350ca9cf6bf2/nixos/modules/services/x11/desktop-managers/default.nix#L76-L81
          extraSessionCommands = ''
            if [ -e $HOME/.background-image ]; then
              ${pkgs.feh}/bin/feh --bg-${wallpaper.mode} \
                                  ${
                                    lib.optionalString wallpaper.combineScreens
                                    "--no-xinerama"
                                  } \
                                  ${background}
            fi
          '';
        };
      };

      windowManager.default = "i3";
      windowManager.i3 = {
        package = pkgs.i3-gaps;
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          # i3blocks
          i3lock
        ];
      };
    };
  };
}
