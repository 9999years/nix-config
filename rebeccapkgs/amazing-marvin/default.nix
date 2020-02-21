{ pkgs ? import <nixpkgs> { }, ... }:

let appimage = import ../appimage { inherit pkgs; };
in appimage.installAppImage rec {
  name = "Amazing-Marvin";
  version = "1.50.1";
  src = pkgs.fetchurl {
    url = "https://s3.amazonaws.com/amazingmarvin/Marvin-${version}.AppImage";
    sha512 =
      "2vma5crlx5shmwbx1qy5sykcm6vdwd4hvr2x4ndg12xj9psm34979zna3byqvcfa4qfcv0shiq51ih1qf8qczk8jzlkxzasj9x6ndzy";
  };
  bin = "marvin";
}
