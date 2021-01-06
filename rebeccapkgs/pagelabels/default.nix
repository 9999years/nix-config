{ python3, writeShellScriptBin }:
let
  py = python3.withPackages (pypkgs: [
    pypkgs.pagelabels
    # Not declared as a dependency of `pagelabels`, but required.
    pypkgs.pdfrw
  ]);
in writeShellScriptBin "pagelabels" ''
  exec ${py}/bin/python -m pagelabels "$@"
''
