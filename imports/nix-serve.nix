{ config, ... }: {
  users.users.nix-serve = {
    home = "/var/lib/nix-serve";
    createHome = true;
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = config.users.users.nix-serve.home + "/nix-serve-key";
  };

  networking.firewall.allowedTCPPorts = [
    5000 # nix-serve
  ];
}
