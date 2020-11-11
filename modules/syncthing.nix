# Enable extra configuration for Syncthing via the
# `services.syncthing.extraConfig` option.
{ config, pkgs, lib, ... }:
let
  inherit (lib) escapeShellArg optionalString types mkOption mkIf;

  cfg = config.services.syncthing;

  # get the api key by parsing the config.xml
  getApiKey = pkgs.writeShellScript "getAPIKey.sh" ''
    ${pkgs.libxml2}/bin/xmllint \
      --xpath 'string(configuration/gui/apikey)' \
      ${escapeShellArg cfg.configDir}/config.xml
  '';

  extraConfig = pkgs.writeText "extra-syncthing-config.json"
    (builtins.toJSON cfg.extraConfig);

  updateConfig = let
    api = endpoint: ''
      ${pkgs.curl}/bin/curl -Ss \
        -H "X-API-Key: $API_KEY" \
        ${escapeShellArg (cfg.guiAddress + endpoint)}'';
  in pkgs.writeShellScript "merge-syncthing-config.sh" ''
    set -efu
    # wait for syncthing port to open
    until ${pkgs.curl}/bin/curl -Ss ${
      escapeShellArg cfg.guiAddress
    } -o /dev/null; do
      sleep 1
    done

    API_KEY=$(${getApiKey})

    # generate the new config by merging with the nixos config options
    ${api "/rest/system/config"} \
      | ${pkgs.jq}/bin/jq \
        --slurpfile extraConfig ${extraConfig} \
        '. * $extraConfig[0]' \
      | ${api "/rest/system/config"} --data @-

    # restart syncthing after sending the new config
    ${api "/rest/system/restart"} -X POST
  '';

in {
  options = {
    services.syncthing = {
      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Extra Syncthing configuration options, applied as JSON.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.syncthing-init-extra-config = {
      after = [ "syncthing-init.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        RemainAfterExit = true;
        Type = "oneshot";
        ExecStart = updateConfig;
      };
    };
  };
}
