{ lib, dataDir ? "/var/lib/syncthing" }:
let
  devices = {
    "dahurica.becca.ooo" = {
      id = "246UFRP-KOHFFXZ-RJ6SG7Q-KTOKEFL-2HQGJD7-GPZRGG5-7OTXSJJ-3CQTAAJ";
      addresses = [ "tcp://dahurica.becca.ooo" ];
    };
    cervina-windows.id =
      "76RKFLL-KE56JKM-DA4VUWT-TTDF76A-RSTZ5GR-XLMCJMY-EQR7J6J-G54V7AG";
    cervina-nixos.id =
      "4RLOXAM-OKS4A3V-WEC3QXL-SGZOVRX-WWGOOCA-RTWDLXW-DRMWTKK-MEXSNAZ";
    aquatica-nixos.id =
      "TA5A7NS-UVQZMCT-7KHNRQQ-N2CRLYT-NAXP77O-R4WGJEK-RZV3OZX-D265ZQ3";
    aquatica-windows.id =
      "XLLGTC6-DL7BHO2-G3IUJ3T-TNEB63K-2LLKEJJ-YXUADON-GVD2I2M-S73TUQH";
  };
  allDevices = lib.attrNames devices;
in {
  inherit dataDir;
  enable = true;
  openDefaultPorts = true;
  declarative = {
    inherit devices;
    folders = builtins.mapAttrs (name: attrs:
      {
        devices = allDevices;
        label = attrs.id;
        versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600"; # 1 hour
            maxAge = builtins.toString (3600 * 24 * 365 / 2); # 6 months
          };
        };
      } // attrs) {
        pdf = {
          id = "pdf";
          path = "${dataDir}/pdf";
        };
        fonts = {
          id = "fonts";
          path = "${dataDir}/Fonts";
        };
        reaction-images = {
          id = "reaction";
          path = "${dataDir}/reaction-images";
        };
      };
  };
  extraConfig = {
    options = {
      # Disable anonymous usage reports
      urAccepted = -1;
      listenAddresses = [ "tcp://0.0.0.0:22000" "quic://0.0.0.0:22000" ];
      autoUpgradeIntervalH = 0;
      stunServers = [ ];
    };
  };
}
