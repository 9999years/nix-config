{ config, pkgs, lib, ... }:
{
  services.emacs = {
    enable = true;
    defaultEditor = true;
    package = import ./pkg/emacs { inherit (pkgs) emacs; };
  };
}
