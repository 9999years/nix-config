{ config, pkgs, lib, ... }:
{
  imports = [
      <nixos-hardware/dell/xps/15-9550>
  ];

  networking.hostName = "cervina";

  # We need at least 5.2.2 (IIRC) to get the WiFi drivers.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Why is the WiFi card called that!!
  networking.interfaces.wlp59s0.useDHCP = true;

  hardware.acpilight.enable = true;

  services.acpid = {
    enable = true;
    # handlers = {
    #   brightness-up = {
    #     event = "video/brightnessup";
    #     action = "${pkgs.light}/bin/light -A 10";
    #   };
    #   brightness-down = {
    #     event = "video/brightnessdown";
    #     action = "${pkgs.light}/bin/light -U 10";
    #   };
    # };

    lidEventCommands = ''
      ${pkgs.xfce.xfce4-session}/bin/xfce4-session-logout --hibernate
    '';
  };

  # Set the minimum display brightness to "very dim but not COMPLETELY OFF".
  boot.initrd.postDeviceCommands = ''
    ${pkgs.light}/bin/light -N 0.01
  '';

  services.xserver.dpi = 175;

  environment.systemPackages =
    let base = import ./base.nix { inherit pkgs lib; };
    in base.packages ++ (with pkgs; [
      light # backlight control
    ]);
}
