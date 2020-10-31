{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkOption types mkForce;
  cfg = config.services.nix-serve;
in {
  options = {
    services.nix-serve = {
      unixSocket = mkOption {
        type = types.nullOr types.path;
        example = /var/run/nix-serve/nix-serve.sock;
        default = null;
        description = ''
          Instead of an IP address and port, nix-serve can listen on a Unix socket.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nix-serve.serviceConfig = {
      ExecStart = mkForce "${pkgs.nix-serve}/bin/nix-serve " + "--listen "
        + (if cfg.unixSocket == null then
          "${cfg.bindAddress}:${toString cfg.port}"
        else
          "${cfg.unixSocket}") + " " + cfg.extraParams;
    };
  };
}
