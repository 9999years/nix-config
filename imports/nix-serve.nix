{ config, ... }: {
  users.users.nix-serve = {
    home = "/var/lib/nix-serve";
    description = "Runs the nix-serve service";
    createHome = true;
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = users.users.nix-serve.home + "/nix-serve-secret";
  };

  networking.firewall.allowedTCPPorts = [
    5000 # nix-serve
  ];
}
