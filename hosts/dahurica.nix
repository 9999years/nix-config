{ config, pkgs, lib, ... }:
let passwords = import ../resources/passwords.nix;
in {
  imports = [
    ../modules
    <nixpkgs/nixos/modules/virtualisation/openstack-config.nix>
    ../imports/yubikey-server.nix
    ./dahurica-hardware-configuration.nix
  ];

  networking.hostName = "dahurica";

  rebecca = {
    server.enable = true;
    syncthing.server.enable = true;
    hydra.enable = true;
    yubikey.server.enable = true;
    pkgs.core.enable = true;
  };

  users.users = {
    root.hashedPassword = passwords.dahurica.root;
    becca.hashedPassword = passwords.dahurica.becca;
  };

  security.acme = {
    acceptTerms = true;
    email = "rbt@sent.as";
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "cache.dahurica.becca.ooo" = {
        forceSSL = true;
        enableACME = true;
        locations."/".extraConfig = ''
          proxy_pass http://localhost:${toString config.services.hydra.port};
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          add_header       Front-End-Https   on;
        '';
      };
    };
  };

  swapDevices = [{
    device = "/var/swap";
    size = 16000; # 16GB
  }];

  system.stateVersion = "21.03"; # Don't change this.
}
