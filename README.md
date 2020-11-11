# NixOS configuration

`/etc/nixos` to configure my [NixOS] hosts.

**Run `./init.py` after cloning to initialize the repository and/or generate
new configuration files.**

Typically, this repository will live at `~/nix-config`, and `/etc/nixos` will
be a clone of that (`sudo git clone ~/nix-config/ /etc/nixos`).

## `configuration.nix`

`configuration.nix` is a symlink to `hosts/$HOSTNAME.nix`, which in turn
imports `hosts/$HOSTNAME-hardware-configuration.nix`.

`init.py` will generate that symlink and configuration file if it doesn't
already exist.

## `hosts/`: machine-specific configuration

The `hosts/` directory contains `$HOSTNAME.nix` and
`$HOSTNAME-hardware-configuration.nix` for each host.

`$HOSTNAME.nix` contains configuration for specific machines that aren't
shared.

## `imports/`

Configuration sets that may be shared between machines to enable/disable
specific features.

Most notable is `imports/packages.nix`, which lists packages to be installed.

## `resources/`

Resources for configuration; may include hashed passwords (hopefully
`.gitignore`'d!), SSH keys, that kind of thing.

## `modules/`

Extra NixOS modules.

## `non-nixos/`

Patterns for using [nixpkgs] on machines *without* NixOS installed, such as
[Pop!_OS] or MacOS.

## `qcow2/`

Scripts / files for generating bootable [copy-on-write disk images][qcow2] for
[QEMU].

## `overlays/`

[nixpkgs] overlays; `overlays/all.nix` is a list of all overlays and
`overlays/default.nix` is an attrset of overlays.

## `rebeccapkgs/`

A [nixpkgs]-like repository (in the sense of a package repository, not a git
repository) using the [inputs] and [`callPackage`] design patterns. rebeccapkgs
contains various packages and derivations not in nixpkgs.

[nixpkgs]: https://github.com/NixOS/nixpkgs/
[NixOS]: https://nixos.org/
[Pop!_OS]: https://system76.com/pop
[inputs]: https://nixos.org/guides/nix-pills/inputs-design-pattern.html
[callPackage]: https://nixos.org/guides/nix-pills/callpackage-design-pattern.html
[qcow2]: https://en.wikipedia.org/wiki/Qcow
[QEMU]: https://www.qemu.org/
