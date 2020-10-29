# See: `man 5 configuration.nix`
# See: `nixos-help`
{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ./hosts/this.nix ];
}
