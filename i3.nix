{ config, pkgs, lib, ... }:
{
  services.xserver = {
    enable = lib.mkDefault true;
    dpi = lib.mkDefault 175;
    libinput = {
      enable = true;
      naturalScrolling = true; # Windows-style, baby!
    };

    desktopManager = {
      default = "xfce";
      wallpaper.mode = "fill";
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
      xterm.enable = false;
    };

    # NixOS incorrectly guesses that xfce (or maybe xfwm...?) can handle setting
    # the background. It cannot -- at least not when we're using it like this,
    # so we have to patch the script back in. It just uses feh to set the background.
    # https://github.com/NixOS/nixpkgs/blob/ae1cb0bdf98a325062eb9c5bd6af350ca9cf6bf2/nixos/modules/services/x11/desktop-managers/default.nix#L76-L81
    services.xserver.desktopManager.xfce.extraSessionCommands =
      let cfg = config.services.xserver;
      in ''
            if [ -e $HOME/.background-image ]; then
              ${pkgs.feh}/bin/feh --bg-${cfg.wallpaper.mode} \
                                  ${lib.optionalString cfg.wallpaper.combineScreens "--no-xinerama"} \
                                  $HOME/.background-image
            fi
      '';

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
}
