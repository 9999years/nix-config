{ config, pkgs, lib, ... }: {
  services.syncthing = rec {
    enable = true;
    user = "becca";
    configDir = "/home/${user}/.config/syncthing";
    dataDir = "/home/${user}";
    declarative = {
      devices = {
        cervina.id =
          "CJBBCGF-MWA6CVR-NPR5C57-7RXNFGR-ITIBB7S-WS25XW7-HOXVPOO-SBNKSAT";
        aquatica.id =
          "OQ3QP4K-BP77TZU-GLG2BAV-I4TZ36S-C75DQYY-PQTKHOI-VX7S5L4-B4R7UQQ";
      };
      folders = {
        "${dataDir}/pdf" = {
          id = "pdf";
          label = "pdf";
          devices = [ "cervina" "aquatica" ];
        };
        "${dataDir}/Fonts" = {
          id = "fonts";
          label = "fonts";
          devices = [ "cervina" "aquatica" ];
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ unstable.syncthingtray ];
}
