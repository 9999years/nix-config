# See: https://nixos.wiki/wiki/Overlays#Applying_overlays_automatically
self: super:
let
  inherit (builtins) foldl' attrValues;
  inherit (super.lib) flip extends;
  overlays = attrValues (import ../.);

  # Apply all overlays to the input of the current "main" overlay
in foldl' (flip extends) (_: super) overlays self
