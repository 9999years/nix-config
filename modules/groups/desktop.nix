{ config, pkgs, lib, options, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.rebecca.desktop;

in {
  options.rebecca.desktop = {
    enable = mkEnableOption "Desktop configuration";
  };

  config = mkIf cfg.enable {
    rebecca = {
      git.enable = true;
      plasma5.enable = true;
      yubikey.desktop.enable = true;
      syncthing.desktop.enable = true;
      printing.enable = true;
    };

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      grub.useOSProber = true;
    };

    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
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

    documentation = {
      dev.enable = true;
      nixos.includeAllModules = true;
    };

    # environment.systemPackages = packages.all;  # TODO: Fix packages
    nixpkgs.overlays = lib.attrValues (import ../../overlays);
    nix.nixPath = options.nix.nixPath.default
      ++ [ "nixpkgs-overlays=/etc/nixos/overlays/nix-path/" ];

    # Check https://nixos.org/manual/nixos/stable/release-notes.html before changing!
    system.stateVersion = "20.09";
  };
}
