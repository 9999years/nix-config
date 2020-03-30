{ stdenv, fetchurl, vscode-utils }:
vscode-utils.buildVscodeExtension rec {
  name = "vscode-cpptools";
  vscodeExtUniqueId = "ms-vscode.cpptools";
  version = "0.27.0-insiders5";
  src = fetchurl {
    name = "ms-vscode.cpptools.zip";
    url =
      "https://github.com/microsoft/vscode-cpptools/releases/download/${version}/cpptools-linux.vsix";
    sha512 =
      "3kr0n96fph0hz4x2hyid38rj50lm16w8br75ihkrzrw0qps8pvz19hxslj97ljrc93hm7kz7kacqmpk87gjsc2q9d2cbf4yby3jywdj";
  };
  dontPatchElf = false;
  dontStrip = false;
}
