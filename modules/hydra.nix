{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.hydra;

  inherit (lib)
    mapAttrsToList escapeShellArg optional optionalString concatStringsSep
    concatMapStringsSep filterAttrs;
  hydra-users = import ../resources/hydra-users.nix;

in {
  options.berry.hydra = {
    enable = mkEnableOption "Hydra CI server (experimental!)";
  };

  config = mkIf cfg.enable {
    services.hydra = {
      enable = true;
      hydraURL = "https://cache.dahurica.becca.ooo";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [ ];
      useSubstitutes = false;
    };

    systemd.services.hydra-user-init = {
      wantedBy = [ "multi-user.target" ];
      after = [ "hydra-server.service" ];
      description = "Initialize Hydra users";
      serviceConfig = {
        Type = "oneshot";
        User = "hydra";
        ExecStart = let
          userAttrFlags = {
            fullName = "--full-name";
            emailAddress = "--email-address";
          };
        in ''
          ${concatStringsSep "\n" (mapAttrsToList (name: attrs:
            "${config.services.hydra.package}/bin/hydra-create-user ${
              escapeShellArg name
            } " + (concatStringsSep " " ((mapAttrsToList
              (name: val: userAttrFlags.${name} + " ${escapeShellArg val}")
              (filterAttrs (name: val: userAttrFlags ? ${name}) attrs))
              ++ (map (role: "--role ${escapeShellArg role}")
                (attrs.roles or [ ]))))) hydra-users)}
        '';
      };
    };
  };
}
