# Configuration for servers; non-graphical environments that need ssh, etc.
{ config, pkgs, lib, ... }:
let
  packages = import ./packages.nix { inherit pkgs; };
  overlays = import ../overlays;
in {
  imports = [
    ./common.nix
    ./git.nix
    ./plasma5.nix
    ./yubikey.nix
    ./syncthing.nix
    ./printing.nix
    ../hosts/this.nix
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
    grub.useOSProber = true;
  };

  # TODO: upgrade kernel back to 'latest' once nvidia drivers are fixed for 5.9
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_5_8;
  # Set the font earlier in the boot process.
  console.earlySetup = true;

  hardware.enableRedistributableFirmware = true;

  networking = {
    networkmanager.enable = true;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    firewall.enable = false;
  };

  services.thermald.enable = true;

  sound.enable = true;

  i18n = {
    # Note: We don't set a font because sometimes the generated
    # hardware-configuration.nix picks a better (larger) one for high-DPI displays.
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ uniemoji typing-booster ];
    };
  };

  # Don't confuse windows with a UTC timestamp.
  time.hardwareClockInLocalTime = true;

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    becca = {
      extraGroups = [ "wheel" "audio" "sound" "video" "networkmanager" ];
    };
  };

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  nix = {
    trustedBinaryCaches =
      [ "https://cache.nixos.org" "https://all-hies.cachix.org" ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
    ];
    trustedUsers = [ "root" "becca" ];
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = packages.sets.fonts;
    fontconfig.defaultFonts = {
      emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
      monospace =
        [ "PragmataPro Mono Liga" "Hack" "IBM Plex Mono" "Fira Mono" ];
    };
  };

  documentation = {
    dev.enable = true;
    nixos.includeAllModules = true;
  };

  environment.systemPackages = packages.all;
  nixpkgs.overlays = lib.attrValues overlays;

  system.stateVersion = "20.03"; # Don't change this. Check the docs first.
}
