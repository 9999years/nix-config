{ config, pkgs, lib, ... }:
let
  inherit (pkgs) writeText;
  inherit (lib) concatStringsSep mapAttrsToList;
  keys = import ../resources/yubikeys.nix;
  u2fAuth = keyAttrs:
    concatStringsSep "\n"
    (mapAttrsToList (user: keys: user + ":" + (concatStringsSep ":" keys))
      keyAttrs);
  u2fAuthFile = keyAttrs: writeText "u2f_mappings" (u2fAuth keyAttrs);
in {
  # Yubikey support
  services.pcscd.enable = lib.mkDefault true;
  services.udev.packages = with pkgs;
    lib.mkDefault [ libu2f-host yubikey-personalization pam_u2f ];
  environment.shellInit = lib.mkDefault ''
    export GPG_TTY=$(tty)
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  '';
  programs = {
    ssh.startAgent = lib.mkDefault false;
    gnupg.agent = {
      enable = lib.mkDefault true;
      enableSSHSupport = true;
    };
  };

  security.pam = {
    enableSSHAgentAuth = true;
    services.sudo.sshAgentAuth = true;
    u2f = {
      enable = true;
      appId = "pam://becca.ooo";
      cue = true;
      authFile = with keys;
        u2fAuthFile {
          root = [ mobile cervina aquatica ];
          becca = [ mobile cervina aquatica ];
        };
    };
  };
}
