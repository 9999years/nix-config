{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.yubikey.server;

  inherit (pkgs) writeText;
  inherit (lib) concatStringsSep mapAttrsToList;
  keys = import ../resources/yubikeys.nix;
  u2fAuth = keyAttrs:
    concatStringsSep "\n"
    (mapAttrsToList (user: keys: user + ":" + (concatStringsSep ":" keys))
      keyAttrs);
  u2fAuthFile = keyAttrs: writeText "u2f_mappings" (u2fAuth keyAttrs);
in {
  options.berry.yubikey.server = {
    enable = mkEnableOption "YubiKey authorization";
  };

  config = mkIf cfg.enable {
    security.pam = {
      enableSSHAgentAuth = true;
      services.sudo = {
        u2fAuth = true;
        yubicoAuth = true;
        sshAgentAuth = true;
      };

      yubico = {
        enable = true;
        # 16 is just a magic number:
        #    https://developers.yubico.com/yubico-pam/YubiKey_and_SSH_via_PAM.html
        id = "16";
      };

      u2f = {
        enable = true;
        appId = "pam://becca.ooo";
        cue = true;
        authFile = with keys.${config.networking.hostName};
          u2fAuthFile {
            root = [ mobile cervina aquatica ];
            berry = [ mobile cervina aquatica ];
          };
      };
    };
  };
}
