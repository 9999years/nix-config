self: super:
let appimage = import ../pkg/appimage { pkgs = self; };
in {
    standardnotes = (appimage.installAppImage {
        inherit (super.standardnotes) name version src;
        bin = "standard-notes";
    }) // {
        inherit (super.standardnotes) pname meta;
    };
}