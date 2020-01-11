{ config, pkgs, lib, ... }:
{
  # Yubikey support
  services.pcscd.enable = lib.mkDefault true;
  services.udev.packages = with pkgs; lib.mkDefault [
    libu2f-host
    yubikey-personalization
  ];
  environment.shellInit = lib.mkDefault ''
    export GPG_TTY=$(tty)
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
  hardware.u2f.enable = lib.mkDefault true;
  programs = {
    ssh.startAgent = lib.mkDefault false;
    gnupg.agent = {
      enable = lib.mkDefault true;
      enableSSHSupport = true;
    };
  };
}
