{ config, pkgs, lib, ... }: {
  imports = [ ../imports/desktop.nix ./aquatica-hardware-configuration.nix ];

  networking.hostName = "aquatica";

  networking = {
    useDHCP = false;
    interfaces = {
      enp4s1.useDHCP = true;
      enp5s0.useDHCP = true;
      wlp4s0.useDHCP = true;
    };
  };

  environment.systemPackages = with pkgs; [
    mdadm # RAID drives
    ntfs3g # ntfs mounting support
    slack
    # ripcord
    openjdk14_headless
    alsaTools
  ];

  nix.maxJobs = 8;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  boot.loader.grub.fontSize = 24;

  console.packages = with pkgs; [ terminus_font ];
  console.font = "ter-c24n";

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;

  services.xserver.dpi = 144;

  services.today_tmp = {
    enable = true;
    user = "becca";
    repository = "${config.users.users.becca.home}/.config/today_tmp/repo";
    workspace = "${config.users.users.becca.home}/Documents/tmp";
  };

  # Don't let USB devices wake the computer from sleep.
  hardware.usb.wakeupDisabled = [
    {
      # Logitech wireless mouse receiver
      vendor = "046d";
      product = "c52b";
    }
    {
      # Pok3r keyboard
      vendor = "04d9";
      product = "0141";
    }
  ];

  # Sound
  sound.enableOSSEmulation = false;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio.enable = true;
  hardware.enableAllFirmware = true;
  boot.extraModprobeConfig = ''
    options snd_hda_intel index=1,0
    options snd_usb_audio
  '';

  # Drives
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/c" = {
    device = "/dev/disk/by-uuid/D854297E5429610C";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.becca.uid}" ];
  };

  # fileSystems."/mnt/d" = {
  # device = "/dev/disk/by-partuuid/25324fe6-c414-11e2-bb89-c85593649ce7";
  # fsType = "ntfs";
  # options = [ "rw" "uid=${builtins.toString config.users.users.becca.uid}" ];
  # };

  fileSystems."/mnt/e" = {
    device = "/dev/disk/by-uuid/4ED6AD0AD6ACF37F";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.becca.uid}" ];
  };

  # RAID 1 volume; /dev/sdb and /dev/sdc
  fileSystems."/mnt/mirrored" = {
    device = "/dev/disk/by-uuid/7CC46C67C46C259C";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.becca.uid}" ];
  };
}
