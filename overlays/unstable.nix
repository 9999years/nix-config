self: super: {
  unstable = import (fetchTarball
    "https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz") {
      config = { allowUnfree = true; };
    };
}
