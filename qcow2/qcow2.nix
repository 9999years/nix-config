# See: ./build.sh
{ config, pkgs, lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/virtualisation/openstack-config.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ./HOSTNAME.nix
  ];

  system.build.openstackImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
    inherit lib config;
    pkgs = import <nixpkgs> {
      inherit (pkgs) system;
    }; # ensure we use the regular qemu-kvm package
    diskSize = 8192;
    format = "qcow2";
    configFile = pkgs.writeText "configuration.nix" ''
      {
        imports = [ <nixpkgs/nixos/modules/virtualisation/openstack-config.nix> ./HOSTNAME.nix ];
      }
    '';
  };
}
