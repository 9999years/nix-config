{ config, pkgs, lib, ... }: {
  services.syncthing = rec {
    enable = true;
    user = "becca";
    configDir = "/home/${user}/.config/syncthing";
    dataDir = "/home/${user}/Documents";
    declarative = rec {
      devices = {
        cervina-windows.id =
          "76RKFLL-KE56JKM-DA4VUWT-TTDF76A-RSTZ5GR-XLMCJMY-EQR7J6J-G54V7AG";
        cervina-nixos.id =
          "4RLOXAM-OKS4A3V-WEC3QXL-SGZOVRX-WWGOOCA-RTWDLXW-DRMWTKK-MEXSNAZ";
        aquatica-nixos.id =
          "TA5A7NS-UVQZMCT-7KHNRQQ-N2CRLYT-NAXP77O-R4WGJEK-RZV3OZX-D265ZQ3";
        aquatica-windows.id =
          "XLLGTC6-DL7BHO2-G3IUJ3T-TNEB63K-2LLKEJJ-YXUADON-GVD2I2M-S73TUQH";
      };
      folders = let
        allDevices = lib.attrNames devices;
        pictures = "/home/${user}/Pictures";
      in {
        "${dataDir}/pdf" = {
          id = "pdf";
          label = "pdf";
          devices = allDevices;
        };
        "${dataDir}/Fonts" = {
          id = "fonts";
          label = "fonts";
          devices = allDevices;
        };
        "${pictures}/reaction" = {
          id = "reaction";
          label = "reaction";
          devices = allDevices;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ syncthingtray ];
}
