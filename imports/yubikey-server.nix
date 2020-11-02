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
  security.pam = {
    enableSSHAgentAuth = true;
    services.sudo = {
      u2fAuth = true;
      sshAgentAuth = true;
    };
    u2f = {
      enable = true;
      debug = true;
      appId = "pam://becca.ooo";
      cue = true;
      authFile = with keys.${config.networking.hostName};
        u2fAuthFile {
          root = [ mobile cervina aquatica ];
          becca = [ mobile cervina aquatica ];
        };
    };
  };
}
