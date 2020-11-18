{ config, pkgs, lib, ... }:
let
  inherit (lib)
    concatStringsSep escapeShellArg optionalString optional toLower forEach
    types mkOption mkEnableOption mkIf hasInfix;
  inherit (types) str;
  cfg = config.services.today_tmp;

in {
  options.services.today_tmp = {
    enable = mkEnableOption "today_tmp service";
    user = mkOption {
      description = "User for today_tmp to run as.";
      example = "becca";
      type = str;
    };
    repository = mkOption {
      description = "Temporary repository";
      example = "/home/becca/.config/today_tmp/repo";
      type = str;
    };
    workspace = mkOption {
      description = "Working directory";
      example = "/home/becca/Documents/tmp";
      type = str;
    };
    dates = mkOption {
      description =
        "When to run the today_tmp script; see <code>systemd.time(7)</code>.";
      default = "04:00";
      example = "weekly";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.today-tmp = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.gitAndTools.git ];
      description = "keeps a daily temporary folder linked to a repository";
      serviceConfig = {
        User = cfg.user;
        Type = "oneshot";
        ExecStart = concatStringsSep " " [
          "${pkgs.python38}/bin/python"
          "${./today_tmp.py}"
          "--repo-path ${escapeShellArg cfg.repository}"
          "--working-path ${escapeShellArg cfg.workspace}"
        ];
      };
    };

    systemd.timers.today-tmp = {
      description = "tells today-tmp when to refresh the daily folder";
      timerConfig = {
        # Run on startup if we missed a run.
        Persistent = true;
        OnCalendar = cfg.dates;
      };
    };
  };
}
