{ lib, ... }: {
  services.syncthing = import ../resources/syncthing-base.nix {
    inherit lib;
    dataDir = "/var/lib/syncthing";
  };
}
