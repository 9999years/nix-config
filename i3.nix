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
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
      xterm.enable = false;
      wallpaper.mode = "fill";
    };

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
