{ stdenv, lib, fetchFromGitHub, python38, fzf }:
let
  spdxVersion = "v3.10";
  spdxDataRaw = fetchFromGitHub {
    owner = "spdx";
    repo = "license-list-data";
    rev = spdxVersion;
    sha256 = "1zza0jrs82112dcjqgkyck2b7hv4kg9s10pmlripi6c1rs37av14";
  };
in stdenv.mkDerivation {
  pname = "spdx-tool";
  version = "1.0.4";
  src = ./.;
  buildInputs = [ python38 fzf ];
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p "$out/share/spdx-tool/"

    ${python38}/bin/python \
        ./gen-short-license-list.py \
        "${spdxDataRaw}/json/licenses.json" \
        > "$out/share/spdx-tool/license-list.txt"

    cp --recursive "${spdxDataRaw}/text" "$out/share/spdx-tool/licenses"
    cp "${spdxDataRaw}/json/licenses.json" "$out/share/spdx-tool/licenses.json"

    substituteInPlace spdx-info.py \
      --subst-var-by licenseJson "$out/share/spdx-tool/licenses.json"

    substituteInPlace spdx.py \
      --subst-var-by licenseJson "$out/share/spdx-tool/licenses.json" \
      --subst-var-by infoHelper "$out/share/spdx-tool/spdx-info.py" \
      --subst-var-by shortLicenseList "$out/share/spdx-tool/license-list.txt" \
      --subst-var-by licenseTextDir "$out/share/spdx-tool/licenses" \
      --subst-var-by spdxVersion "${spdxVersion}" \
      --subst-var version

    cp spdx-info.py "$out/share/spdx-tool/"

    mkdir -p "$out/bin"
    cp spdx.py "$out/bin/spdx"
  '';
}
