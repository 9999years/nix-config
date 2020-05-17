# man 5 configuration.nix
# nixos-help
{ config, pkgs, lib, ... }:
let
  unstableTarball = fetchTarball
    "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz";
  unstable = import unstableTarball { config = config.nixpkgs.config; };
  packages = import ./packages.nix { inherit pkgs unstable; };
  overlays = import ./overlays;
in {
  imports = [
    ./hardware-configuration.nix

    ./git.nix
    ./plasma5.nix
    ./yubikey.nix
    ./syncthing.nix
    ./printing.nix
    ./this.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub = {
      useOSProber = true;
      configurationLimit = 10;
      font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
      fontSize = 24;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Set the font earlier in the boot process.
  boot.earlyVconsoleSetup = true;
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
    consoleKeyMap = "us";
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
  users.users.becca = {
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
    useSandbox = true;
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

  system.stateVersion = "19.09"; # Did you read the comment?
}
