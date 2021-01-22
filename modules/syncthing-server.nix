{ config, pkgs, lib, ... }:
let
  inherit (lib) recursiveUpdate types mkEnableOption mkOption mkIf;

  cfg = config.berry.syncthing.server;

in {
  options.berry.syncthing.server = {
    enable = mkEnableOption "Syncthing service (server-side)";
  };

  config = mkIf cfg.enable {
    services.syncthing = import ../resources/syncthing-base.nix {
      inherit lib;
      dataDir = "/var/lib/syncthing";
    };
  };
}
