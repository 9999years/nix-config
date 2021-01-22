{ config, pkgs, lib, ... }: {
  imports = [ ../modules ./aquatica-hardware-configuration.nix ];

  berry = {
    desktop.enable = true;
    fonts.enable = true;
    pkgs.all.enable = true;
  };

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
    user = "berry";
    repository = "${config.users.users.berry.home}/.config/today_tmp/repo";
    workspace = "${config.users.users.berry.home}/Documents/tmp";
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
    {
      # Razer Basilisk mouse
      vendor = "1532";
      product = "0064";
    }
  ];

  # Sound
  sound.enableOSSEmulation = false;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.pulseaudio.enable = true;
  hardware.enableAllFirmware = true;
  # Okay, this modprobe stuff is horrible to deal with. Relevant resources:
  # See: https://www.alsa-project.org/wiki/Matrix:Module-hda-intel
  # See: https://www.alsa-project.org/wiki/Matrix:Module-usb-audio
  # Run:
  #     modinfo soundcore
  #     modinfo snd_hda_intel
  #     modinfo snd_usb_audio
  # I still don't really understand it, but this seems to work for now.
  # I think there's some relevant source in the linux kernel repo as well, but
  # I couldn't find it when I checked. Maybe check the alsa source too...?
  # NOTE: I *think* this won't work if /tmp won't mount (see comment attached
  # to `tmpOnTmpfs` below); check that if this breaks before messing with this
  # stuff again.
  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=1 model=auto
    options snd_usb_audio enable=1
  '';

  # Drives
  boot = {
    supportedFilesystems = [ "ntfs" ];
    cleanTmpDir = true; # Wipe /tmp on boot.
    # Okay, aquatica *really* doesn't like mounting /tmp as of 2021-01-14
    # (evening). systemd gives this error message:
    #     systemd[1]: Mounting /tmp...
    #     mount[8910]: mount: /tmp: special device tmpfs does not exist.
    #     systemd[1]: tmp.mount: Mount process exited, code=exited, status=32/n/a
    #     systemd[1]: tmp.mount: Failed with result 'exit-code'.
    #     systemd[1]: Failed to mount /tmp.
    # Sure. Can't figure out a way to avoid this, so we don't *really* need
    # /tmp in RAM, do we...? :)
    tmpOnTmpfs = false;
  };

  fileSystems."/mnt/c" = {
    device = "/dev/disk/by-uuid/D854297E5429610C";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.berry.uid}" ];
  };

  # fileSystems."/mnt/d" = {
  # device = "/dev/disk/by-partuuid/25324fe6-c414-11e2-bb89-c85593649ce7";
  # fsType = "ntfs";
  # options = [ "rw" "uid=${builtins.toString config.users.users.berry.uid}" ];
  # };

  fileSystems."/mnt/e" = {
    device = "/dev/disk/by-uuid/4ED6AD0AD6ACF37F";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.berry.uid}" ];
  };

  # RAID 1 volume; /dev/sdb and /dev/sdc
  fileSystems."/mnt/mirrored" = {
    device = "/dev/disk/by-uuid/7CC46C67C46C259C";
    fsType = "ntfs";
    options = [ "rw" "uid=${builtins.toString config.users.users.berry.uid}" ];
  };
}
