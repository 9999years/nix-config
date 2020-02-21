{ config, pkgs, lib, ... }: {
  services.emacs = {
    enable = true;
    defaultEditor = true;
  };
}
