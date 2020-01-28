{ pkgs ? import <nixpkgs> { }, ... }:
with pkgs;
let inherit (python2Packages) pygtk wrapPython python;
in stdenv.mkDerivation rec {
  name = "Glimpse";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "glimpse-editor";
    repo = "Glimpse";
    rev = "v${version}";
    url =
      "https://github.com/glimpse-editor/Glimpse/archive/v${version}.tar.gz";
    sha512 =
      "1lmm8c7q95rmywrdxjxfx0q4lchymlsk2dqiw7av1zscxm4g1yl0ccw96ic0gpffh98ak3g4317mkffb3nidbc9n4v6g54xj42w7jpc";
  };

  meta = with stdenv.lib; {
    description = "A Photo Editor For Everyone";
    longDescription = ''
      Glimpse is an open source image editor based on the GNU Image
      Manipulation Program. The goal is to experiment with new ideas and
      expand the use of free software.
    '';
    license = licenses.gpl;
    homepage = https://glimpse-editor.org/;
    platforms = platforms.all;
    maintainers = [
      {
        name = "Chris";
        github = "BrainBlasted";
        githubId = 29347290;
      }
      {
        name = "Clipsey (Luna)";
        github = "Member1221";
        githubId = 7032834;
      }
      {
        name = "Bobby Moss";
        github = "TrechNex";
        githubId = 45732696;
      }
    ];
  };

  debsBuildBuild = [ stdenv.cc ];

  nativeBuildInputs = with pkgs; [
    autoconf
    autoreconfHook
    automake
    pkg-config
    gcc
    gettext
    intltool
    wrapPython
  ];

  buildInputs = with pkgs; [
    libtool # 2020-01-21: "Major version might be too new (2.4.6)"
    aalib
    babl
    cairo
    fontconfig
    freetype
    gdk-pixbuf
    gegl
    gegl_0_4
    gexiv2
    ghostscript
    glib
    glib-networking
    gnome3.libgudev
    gnome3.librsvg
    gnome3.webkitgtk
    gtk2
    gtk2-x11
    gtk_doc
    harfbuzz
    isocodes
    lcms
    lcms2
    libexif
    libheif
    libjpeg
    libmng
    libmypaint
    libpng
    librsvg
    libtiff
    libwebp
    libwmf
    libxslt
    libzip
    mypaint-brushes
    openexr
    openjpeg
    pango
    poppler
    poppler_data
    pygtk
    python
    wrapPython
    shared-mime-info
    webkit
    xorg.libXpm
    zlib
  ];

  propagatedBuildInputs = [ gegl ];

  pythonPath = [ pygtk ];

  # Check if librsvg was built with --disable-pixbuf-loader.
  PKG_CONFIG_GDK_PIXBUF_2_0_GDK_PIXBUF_MODULEDIR =
    "${librsvg}/${gdk-pixbuf.moduleDir}";

  preAutoreconf = ''
    ${gtk_doc}/bin/gtkdocize
  '';

  GIO_MODULE_DIR = "${glib-networking}/${glib.passthru.gioModuleDir}";

  configureFlags = [
    "--without-webkit" # old version is required
    "--with-bug-report-url=https://github.com/NixOS/nixpkgs/issues/new"
    "--with-icc-directory=/run/current-system/sw/share/color/icc"
    # fix libdir in pc files (${exec_prefix} needs to be passed verbatim)
    "--libdir=\${exec_prefix}/lib"
  ];
}
