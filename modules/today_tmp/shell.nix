{ pkgs ? import <nixpkgs> { } }:
let
  inherit (pkgs) mkShell python3 lib;
  init_coc_python = pkgs.berry.init_coc_python or null;
in mkShell {
  buildInputs = [
    (python3.withPackages (py:
      with py; [
        pytest
        black
        jedi
        mypy
        pep8
        pydocstyle
        pylint
        isort
        hypothesis
        rope
        ptpython
      ]))
  ];

  shellHook = lib.optionalString (init_coc_python != null)
    "${init_coc_python}/bin/init_coc_python.py";
}
