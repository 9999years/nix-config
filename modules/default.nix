# So I have a few things I want to do here, that I want to do with the module
# sytem in specific, but I'm not sure how to split them up.
#
# We have
# 1. Implementing features (Git support, YubiKey support, etc.)
#    (i.e. as options under `berry`)
#    - Do I want the option names to match the filesystem...?
#      - No
#    - Done
# 2. Enabling features for different groups (desktops, laptops, servers, etc.)
#     - A `groups` subdir!
#     - Done...ish
# 3. Specifying relations between groups (servers are headless, desktops load
#    plasma5, etc)
#    - I guess these can just be in `groups` also :)
# 4. Loading all the correct option definitions in `./default.nix`
# 5. Enabling the correct groups for a node.
#    - In `../hosts/` still
# 6. Load different packages.
#    - Might have a few different "levels"
#       - E.g. "core" packages are always loaded
#    - "work" packages / "personal" packages?
#       - Don't install social media stuff on work computers, etc.
#    - gui / x11 packages

{ ... }: {
  imports = [
    ./emacs.nix
    ./fonts.nix
    ./git.nix
    ./hydra.nix
    ./i3.nix
    # ./languages.nix
    ./nvim.nix
    ./packages.nix
    ./plasma5.nix
    ./printing.nix
    ./syncthing-desktop.nix
    ./syncthing.nix
    ./syncthing-server.nix
    ./today_tmp
    ./usb-wakeup-disable.nix
    ./xserver-packages.nix
    ./yubikey-desktop.nix
    ./yubikey-server.nix

    ./groups
  ];
}
