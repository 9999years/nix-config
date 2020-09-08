{ config, pkgs, lib, ... }: {
  # Credential managment
  services.gnome3.gnome-keyring.enable = lib.mkDefault true;
}
