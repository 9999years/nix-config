# man 5 configuration.nix
# nixos-help
{ config, pkgs, lib, ... }:
let
  packages = import ./imports/packages.nix { inherit pkgs; };
  overlays = import ./overlays;
in {
  imports = [
    ./hardware-configuration.nix

    ./imports/git.nix
    ./imports/plasma5.nix
    ./imports/yubikey.nix
    ./imports/syncthing.nix
    ./imports/printing.nix
    ./hosts/this.nix
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
  boot.kernelPackages = pkgs.linuxPackages_5_8;
  # Set the font earlier in the boot process.
  console = {
    earlySetup = true;
    keyMap = "us";
  };
  boot.tmpOnTmpfs = lib.mkDefault true; # Keep /tmp in RAM

  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.enable = false;

  services.thermald.enable = true;

  sound.enable = true;

  i18n = {
    # Note: We don't set a font because sometimes the generated
    # hardware-configuration.nix picks a better (larger) one for high-DPI displays.
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ uniemoji typing-booster ];
    };
  };

  time = {
    timeZone = "America/New_York";
    # Don't confuse windows with a UTC timestamp.
    hardwareClockInLocalTime = true;
  };

  # Don't forget to set a password with ‘passwd’.
  users.users = {
    becca = {
      isNormalUser = true;
      description = "Rebecca Turner";
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "audio"
        "sound" # Not sure if these are necessary.
        "video" # Not sure if this is necessary.
        "networkmanager"
      ];
      shell = pkgs.fish;
      uid = 1000;
    };
  };

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  programs.fish.enable = true;

  services.emacs.enable = false;

  nix = {
    trustedBinaryCaches = [
      "https://cache.nixos.org"
      "https://all-hies.cachix.org"
      "https://rebecca.cachix.org/"
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
      "rebecca.cachix.org-1:ez7qsiSFZq1mqxY1LmRuGnLS5yD2kmKbsF31qHD/D3U="
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

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = packages.all;
  nixpkgs.overlays = lib.attrValues overlays;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you

  system.stateVersion = "20.03"; # Did you read the comment?
}
