{ stdenv, fetchurl, vscode-utils, glibc, patchelf, zlib }:
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
  propagatedBuildInputs = [ zlib ];
  buildPhase = ''
    chmod +x bin/cpptools
    chmod +x bin/cpptools-srv
    chmod +x debugAdapters/mono.linux-x86_64
    chmod +x debugAdapters/OpenDebugAD7
    chmod +x LLVM/bin/clang-format
    for exe in \
      bin/cpptools \
      bin/cpptools-srv \
      debugAdapters/mono.linux-x86_64 \
      LLVM/bin/clang-format
    do
    ${patchelf}/bin/patchelf \
      --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 \
      $exe
    done

    ${patchelf}/bin/patchelf \
      --add-needed ${zlib}/lib/libz.so.1 \
      LLVM/bin/clang-format
  '';
  dontPatchElf = false;
  dontStrip = false;
}
