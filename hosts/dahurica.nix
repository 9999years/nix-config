{ config, pkgs, lib, ... }:
let passwords = import ../resources/passwords.nix;
in {
  imports = [ ../imports/server.nix ../imports/syncthing-server.nix ];

  users.users = {
    root.hashedPassword = passwords.dahurica.root;
    becca.hashedPassword = passwords.dahurica.becca;
  };

  system.stateVersion = "21.03"; # Don't change this.
}
