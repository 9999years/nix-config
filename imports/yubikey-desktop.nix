{ config, pkgs, lib, ... }: {
  # Yubikey support
  services.pcscd.enable = lib.mkDefault true;
  services.udev.packages = with pkgs;
    lib.mkDefault [ libu2f-host yubikey-personalization pam_u2f ];
  programs.ssh.startAgent = true;

  security.pam = {
    enableSSHAgentAuth = true;
    services.sudo.sshAgentAuth = true;
  };
}
