{ config, pkgs, lib, ... }:
let
  cfg = config.services.xserver;

  inherit (lib) mkIf;

in {
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty # terminal
      kitty # terminal
      firefox-bin
      lastpass-cli
      (spotify.override { deviceScaleFactor = 1.66; }) # unfree
      discord # unfree
      # typora # md editor (unfree)
      # rebecca.glimpse
      gimp # admitting defeat
      pinta # paint tool
      inkscape
      gparted
      dosfstools # for fat/fat32 filesystems
      mtools # for fat/fat32 filesystems
      hfsprogs # macos file system support for gparted, etc.
      spectacle # screenshot tool
      gnome3.eog # photo viewer
      qalculate-gtk # calculator
      evince # pdf viewer
      qpdfview # pdf viewer with tabs
      rebecca.background-images
      psensor # view CPU usage / temps, etc.
      rebecca.standardnotes
      calibre # ebook mgmt
      # libreoffice-fresh
      signal-desktop
      rebecca.todoist
      xclip
      rebecca.workflowy # https://workflowy.com/
      rebecca.notion # https://notion.so/
    ];
  };
}
