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
      example = "berry";
      type = str;
    };
    repository = mkOption {
      description = "Temporary repository";
      example = "/home/berry/.config/today_tmp/repo";
      type = str;
    };
    workspace = mkOption {
      description = "Working directory";
      example = "/home/berry/Documents/tmp";
      type = str;
    };
    dates = mkOption {
      description = ''
        When to run the today_tmp script; see <code>systemd.time(7)</code>.

        Note that today_tmp will also run on startup and after resuming from
        sleep or hibernation.
      '';
      default = "04:00";
      example = "weekly";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.today-tmp = {
      wantedBy = [ "multi-user.target" "sleep.target" ];
      after = [
        "systemd-suspend.service"
        "systemd-hybrid-sleep.service"
        "systemd-hibernate.service"
      ];
      path = [ pkgs.gitAndTools.git ];
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
      timerConfig = {
        # Run on startup if we missed a run.
        Persistent = true;
        OnCalendar = cfg.dates;
      };
    };
  };
}
