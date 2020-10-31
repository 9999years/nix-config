{ config, pkgs, lib, ... }: {
  imports = [ ../resources/nix-serve-extra.nix ];

  users.users.nix-serve = {
    home = "/var/lib/nix-serve";
    createHome = true;
  };

  services.nix-serve = {
    enable = true;
    unixSocket = "/var/run/nix-serve/nix-serve.sock";
    secretKeyFile = config.users.users.nix-serve.home + "/nix-serve-key";
  };
}
