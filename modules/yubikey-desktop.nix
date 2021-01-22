{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.yubikey.desktop;

in {
  options.berry.yubikey.desktop = {
    enable = mkEnableOption "YubiKey support (laptops/desktops)";
  };

  config = mkIf cfg.enable {
    # Yubikey support
    services.pcscd.enable = lib.mkDefault true;
    services.udev.packages = with pkgs;
      lib.mkDefault [ libu2f-host yubikey-personalization pam_u2f ];
    programs.ssh.startAgent = true;

    security.pam = {
      enableSSHAgentAuth = true;
      services.sudo.sshAgentAuth = true;
    };
  };
}
