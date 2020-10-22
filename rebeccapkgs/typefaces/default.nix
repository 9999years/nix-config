{ pkgs, stdenv, lib, fetchurl, fetchzip, fetchFromGitLab, fetchFromGitHub }:
let
  fetchsinglefont = dir: args:
    stdenv.mkDerivation (lib.recursiveUpdate args {
      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;
      installPhase = ''
        mkdir -p "$out/share/fonts/${dir}"
        cp "$src" "$out/share/fonts/${dir}/$(stripHash "$src")"
      '';

      meta = {
        license = args.meta.license or stdenv.lib.licenses.ofl;
        platforms = stdenv.lib.platforms.all;
      };
    });

  fetchotf = fetchsinglefont "opentype";
  fetchttf = fetchsinglefont "truetype";

  fetchfont = args:
    stdenv.mkDerivation (lib.recursiveUpdate args {
      dontConfigure = true;
      dontBuild = true;
      installPhase = (args.installPhase or "") + ''
        mkdir -p $out/share/fonts/{opentype,eot,svg,truetype,woff,woff2}
        find ${lib.escapeShellArg (args.baseDir or ".")} \
            -name "__MACOSX" -prune \
          -o -iname "_*" -prune \
          -o ! -name ".*" \
          \( -iname "*.otf" \
          -o -iname "*.eot" \
          -o -iname "*.svg" \
          -o -iname "*.ttf" \
          -o -iname "*.woff" \
          -o -iname "*.woff2" \) \
          -type f \
          -exec cp --update -t $out/share/fonts/ {} +

        cd $out/share/fonts
        find . -maxdepth 1 -name "*.otf" -exec mv -t opentype/ {} +
        find . -maxdepth 1 -name "*.eot" -exec mv -t eot/ {} +
        find . -maxdepth 1 -name "*.svg" -exec mv -t svg/ {} +
        find . -maxdepth 1 -name "*.ttf" -exec mv -t truetype/ {} +
        find . -maxdepth 1 -name "*.woff" -exec mv -t woff/ {} +
        find . -maxdepth 1 -name "*.woff2" -exec mv -t woff2/ {} +
        find . -type f -executable -exec chmod -x {} +
        find . -maxdepth 1 ! -name "." -type d -exec rmdir --ignore-fail-on-non-empty {} +
      '';
    });

  fetchufr = args:
    fetchfont (lib.recursiveUpdate args { baseDir = "./fonts"; });

  allPkgs = pkgs // helpers;
  callPackage = path: overrides:
    let f = import path;
    in f
    ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

  helpers = { inherit callPackage fetchotf fetchttf fetchfont fetchufr; };

in {
  velvetyne = callPackage ./velvetyne { };
  atkinson-hyperlegible-font = callPackage ./atkinson-hyperlegible-font { };
  dotcolon = callPackage ./dotcolon { };

  bagnard = fetchfont {
    pname = "bagnard-font";
    version = "2015-04-27";
    src = fetchFromGitHub {
      owner = "dconstruct";
      repo = "Bagnard";
      rev = "92146404d08a0a12259b5abb9a658b94f4480058";
      sha256 = "0wl3sc8cc7v3qa5kswgwapymv3w6kxc5wvp2gr8ff155lixdjyf3";
    };
    meta.description =
      "Typeface inspired by the graffiti of an anonymous prisoner of the Napoleonic wars";
  };

  cotham = fetchotf {
    pname = "cotham-font";
    version = "2015-03-08";
    src = fetchurl {
      name = "CothamSans.otf";
      sha256 = "09ybibm3bza7vybx5r7bwmgxv43a53dfsnlsv7jpsj9fp1wl8383";
      url =
        "https://github.com/sebsan/Cotham/blob/master/CothamSans.otf?raw=true";
    };
    meta.description = "Sans serif grotesk typeface";
  };

  gap-sans = fetchufr {
    pname = "gap-sans";
    version = "2016-05-03";
    src = fetchFromGitHub {
      owner = "Interstices-";
      repo = "GapSans";
      rev = "24e59f53bbfac3c7d8e4eb8db89ae828f9f8fba7";
      sha256 = "11xnlfbsg0n3lnrb5v740rfh0zrsmknibng3i68qjkzg7n5frin6";
    };
    meta.description =
      "Fork of the Sani Trixie Sans typeface by GrandChaos9000 redesigned for interstices.io";
  };

  inter = fetchfont rec {
    pname = "inter";
    version = "3.15";
    src = fetchzip {
      sha256 = "05j5s4apmi4np1ycs7qcshmskb4wd5gc1vv9ffqgj0wiqz5apiih";
      stripRoot = false;
      url =
        "https://github.com/rsms/inter/releases/download/v${version}/Inter-${version}.zip";
    };
    meta = {
      description =
        "A typeface specially designed for user interfaces with focus on high legibility";
      longDescription = ''
        Inter is a typeface specially designed for user interfaces with focus
        on high legibility of small-to-medium sized text on computer screens.

        The family features a tall x-height to aid in readability of mixed-case
        and lower-case text. Several OpenType features are provided as well,
        like contextual alternates that adjusts punctuation depending on the
        shape of surrounding glyphs, slashed zero for when you need to
        disambiguate "0" from "o", tabular numbers, etc.
      '';
      homepage = "https://github.com/rsms/inter";
    };
  };

  juniusX = fetchufr {
    pname = "junius-x";
    version = "2020-10-19";
    src = fetchFromGitHub {
      owner = "psb1558";
      repo = "Junicode-New";
      rev = "f6d6d2aba8980f340db0652889b68d92f09ec2d4";
      sha256 = "0yxh50lrmaysilhr6arilg52f6qv8sjx25x37mqry07y8gd75m7m";
    };
    meta = {
      description =
        "A font family for medieval scholars with enough Unicode characters to be widely useful";
      longDescription = ''
        JuniusX (Junicode New) is a completely rebuilt version of Junicode, the
        font for medievalists. When complete, it will offer the full MUFI
        (Medieval Unicode Font Initiative, version 4.0) character set in all
        faces, which will include Light, Regular, Medium, Semibold and Bold
        weights, Condensed, Semicondensed and Regular widths, and (of course)
        roman and italic styles. All fonts will include an expanded set of
        OpenType features—for example, automated transliteration of Latin text
        to runic or Gothic, mirrored runes, historical ligatures (easing access
        to MUFI’s specialized ligatures), old-style figures, and many variant
        letter-shapes.
      '';
      homepage = "https://github.com/psb1558/Junicode-New";
    };
  };

  nimbus-sans-l = fetchfont {
    pname = "nimbus-sans-l";
    version = "2016-07-10";
    src = fetchzip {
      sha256 = "0cqz7kr5npall1w1i8qyxz9p8fppz5s1nfw0snqah2c354a6kxg2";
      stripRoot = false;
      url =
        "https://fontlibrary.org/assets/downloads/nimbus-sans-l/2c1b22cb6708de61d2051f12c90a024e/nimbus-sans-l.zip";
    };
    meta = {
      description = "A free Helvetica-like typeface";
      longDescription = ''
        Nimbus Sans L is a version of Nimbus Sans using Adobe font sources.
        It was designed in 1987. A subset of Nimbus Sans L were released
        under the GPL. Although the characters are not exactly the same,
        Nimbus Sans L has metrics almost identical to Helvetica and Arial.
        (From Wikipedia, the free encyclopedia)
      '';
      homepage = "https://fontlibrary.org/en/font/nimbus-sans-l";
      license = stdenv.lib.licenses.gpl3;
    };
  };

  office-code-pro = fetchfont {
    pname = "office-code-pro";
    version = "1.004";
    src = fetchFromGitHub {
      owner = "nathco";
      repo = "Office-Code-Pro";
      rev = "1.004";
      sha256 = "0znmjjyn5q83chiafy252bhsmw49r2nx2ls2cmhjp4ihidfr6cmb";
    };
    meta = {
      description =
        "a customized version of Source Code Pro, a monospaced sans serif typeface";
      longDescription = ''
        Office Code Pro is a customized version of Source Code Pro, the
        monospaced sans serif originally created by Paul D. Hunt for Adobe
        Systems Incorporated. The customizations were made specifically for
        text editors and coding environments, but are still very usable in
        other applications.
      '';
      homepage = "https://github.com/nathco/Office-Code-Pro";
    };
  };

  routed-gothic = fetchfont {
    pname = "routed-gothic";
    version = "1.0.0";
    src = fetchzip {
      sha256 = "0yl1aqgpmnici0mqfz8b15422sj5fklmr843m9wcwhxmr1i1mca7";
      url =
        "https://webonastick.com/fonts/routed-gothic/download/routed-gothic-ttf.zip";
    };
    meta = {
      description =
        "A clean implementation of a common lettering style found on technical drawings";
      longDescription = ''
        A clean implementation of a common lettering style found on technical
        drawings, engraved office signs, computer and typewriter keyboards, and
        some comic books and avionics from the mid-20th century.

        It’s ugly, and therein lies its beauty.

        I created this font by purchasing a Leroy Lettering set, using Inkscape
        to trace the scanned letterforms of one of its templates, and some
        FontForge Python scripting.

        Other keywords I want people to use to find this font include: Wrico.
      '';
      homepage = "https://webonastick.com/fonts/routed-gothic/";
    };
  };

  dse-typewriter = fetchfont {
    pname = "dse-typewriter";
    version = "2020-05-07";
    baseDir = "ttf";
    src = fetchFromGitHub {
      owner = "dse";
      repo = "dse-typewriter-font";
      rev = "1795eb8b559e1ed1c7c7d2557a2a506888946d80";
      sha256 = "04wnlnzxzzpc3697ljh3l90svqx8d2mk5skj3pknbzfr7cvg2q4f";
    };
    meta = {
      description = "Coding font inspired by early 20th-century typewriters";
      longDescription = ''
        This font is not the result of any scans or traces of samples,
        specimens, or other output from an actual typewriter.

        It's more like an amalgamation of old-school typewriter fonts with
        features semi-arbitrarily picked from each one, as well as a few not in
        use on actual typewriters.
      '';
      homepage = "https://webonastick.com/fonts/dse-typewriter/";
    };
  };

  din-1451 = fetchfont {
    pname = "din-1451";
    version = "1.0.0";
    src = fetchzip {
      sha256 = "0s1cliyvv3hr390ixvnb7hbv491xl2zyn065fb4w39wvcmi7sgy8";
      stripRoot = false;
      url = "https://www.peter-wiegel.de/Fonts/DIN1451breit.zip";
    };
    meta.homepage = "http://www.peter-wiegel.de/DinBreit.html";
  };

  tgl-0-16 = fetchfont {
    pname = "tgl-0-16";
    version = "1.0.0";
    src = fetchzip {
      sha256 = "092qfb2zdk1nhprd691r6vikcr5bsp5b0j6q6w9zq70xs0wrld3i";
      stripRoot = false;
      url = "https://www.peter-wiegel.de/Fonts/TGL_0-16.zip";
    };
    meta.homepage = "http://www.peter-wiegel.de/TGL_0-16.html";
  };

  ms-33558 = fetchfont {
    pname = "ms-33558";
    version = "beta-1.0-2000-04-22";
    src = fetchzip {
      sha256 = "1gc0nk9j97p1c9g8dycy79xj3ndwy2rcs7mm2bg5j0zwz0f4sdir";
      stripRoot = false;
      # Horrible hack: https://github.com/NixOS/nixpkgs/issues/60157#issuecomment-524965720
      url =
        "https://webonastick.com/fonts/other/mil-spec-33558/MS33558FONT.ZIP#.zip";
    };

    meta = {
      description = "Standard military aircraft cockpit font";
      longDescription = ''
        The included truetype font is my version of MS33558, the Military
        Standard for the "Standard form of Numerals and letters for Aircraft
        Instrument Dials". It was traced off of a fax I recieved. The fax was
        distorted, and I cleaned it up as best I could. I'm still not happy
        with some of the lettering, though. If anyone could send me a better
        copy of this standard I'll be happy to update the font in order to
        ensure the highest accuracy. The font has upper and lower case
        letters repeated, because there isn't any lowercase lettering defined
        in the standard.

        I'm open to any suggestions for updates. Contact me at the addresses
        below.

          Derek Higgs
          6516 Ellesmere Drive
          Knoxville TN 37921

          dhiggs@simpits.com

        This font was created using Autocad 14 and Coreldraw 9.0.
      '';
      license = stdenv.lib.licenses.unfree;
    };
  };
}
