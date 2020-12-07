{ stdenvNoCC, fetchurl, imagemagick7 }:
let
  image = size: src:
    stdenvNoCC.mkDerivation rec {
      inherit (src) name;
      inherit src;
      version = "1.0.0";
      dontUnpack = true;
      dontConfigure = true;
      nativeBuildInputs = [ imagemagick7 ];
      buildPhase = ''
        magick convert "$src" \
          -resize "${size}" \
          -quality 90 \
          "$out"
      '';
      dontInstall = true;
      dontFixup = true;
    };
  image-4k = image "3840>";
in stdenvNoCC.mkDerivation {
  name = "rbt-background-image";
  version = "1.0.0";
  srcs = map image-4k [
    (fetchurl {
      url = "https://live.staticflickr.com/809/40680910775_c1eb714fc9_o_d.jpg";
      sha512 =
        "04brp4br5sya6l9d2n35apzp7m63wm40hsddh4dcdbaqfqw511wj68zr1gaj9dzfbvfy9r4da8fxccrnqvlwh97dxxx7ghzrdn2zw0c";
      name = "night-stars.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50306262071_0b89b0a04f_o_d.jpg";
      sha256 = "145f30fr1j1159y07n6b4ka9micmzf0lm42lwkzrmamn66l4adib";
      name = "rooftop-sunset.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50305574683_c3205617d9_o_d.jpg";
      sha256 = "1wwjaix87641i9khxfrwbccbmjj8dwa5zpac57fqc2z54m477vxw";
      name = "jinx-1.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50305574878_86b3afc25b_o_d.jpg";
      sha256 = "0kj436i26ssqkmvdcqpmdfgh77xc2ax4lc1p54xf9sma0ly118sh";
      name = "nyx-1.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/8665/16410436297_2da4f8edc8_o_d.jpg";
      sha256 = "0x09inj4kf75qxg8a27dyyq0cwjqzw8snwb5c0jnvr2xsgzckj5z";
      name = "dustin-adams-waves.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/7486/15959187229_883f9aec54_o_d.jpg";
      sha256 = "0wazcgajaymvssdpr3wywfqkfgwkykr8hzg5vfp3axjy5f10mwl7";
      name = "dustin-adams-moon-girl.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/7520/16016122192_da62f11a74_o_d.jpg";
      sha256 = "0bin66cdd1mfms5b6z5cdw0jkia3galdcx9cc9xv7lwqf9p3q4cb";
      name = "dustin-adams-low-clouds.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5612/15770906412_38800710a3_o_d.jpg";
      sha256 = "0q39ib60bvpgayzb8iqnf3b0r4axc772gh4is0jnjza119zaschd";
      name = "dustin-adams-silhouetted-trees.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5603/14967887864_721f508aba_o_d.jpg";
      sha256 = "174d2zq36pg9b13dyik83hx5h19p90rsnqhn8md6n1cz75g2yijc";
      name = "dustin-adams-niagara.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/3915/15037343711_21d44ae859_o_d.jpg";
      sha256 = "10b313bns0z88mj8m0vjvlmldpgbjcjbj2bc3g2l8wy30f39s1sc";
      name = "dustin-adams-ferns.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5570/14800374839_0d5c606d80_o_d.jpg";
      sha256 = "0pzvzbdins8pq82mjj3ifai8qr60ayf6w4f5530sd5pydsn10has";
      name = "dustin-adams-beach-walk.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/3895/14714845786_650e4d5c4c_o_d.jpg";
      sha256 = "0rl6jissb6w4c61f54z7znil2lf7959pfr1fsryshsjp53r6jwbd";
      name = "dustin-adams-coast-sunset.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5078/14316001100_cb0433c235_o_d.jpg";
      sha256 = "0ayllq34n0zlk2wnm44k48wm2isl31mp4216rjv6i8bs1i1wza05";
      name = "dustin-adams-coast-waves.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/2924/14310066645_6ac397c9a9_o_d.jpg";
      sha256 = "025adc87md9nxscp363830v3n9prvssr0k15dw6yxy6pr8s2nq94";
      name = "dustin-adams-desert-river.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/2896/14310066535_fb27422cc5_o_d.jpg";
      sha256 = "0xw7dg3r1k8mh2g15rzi4f34mh73frqg88w05wap7f29k282hcmm";
      name = "dustin-adams-desert-flora.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/7445/13899997837_66e2ac4838_o_d.jpg";
      sha256 = "15wdwypmlwg7jnfcdmr2fc1p13q3bdz9866nqn33qlwwimqllab1";
      name = "dustin-adams-canal.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/7410/12939825813_7f0c48a92b_o_d.jpg";
      sha256 = "0lg63fff9q747wyqpw5lziiz0y1pihn7padkcsd0ya6k5mav5sgk";
      name = "dustin-adams-forest-road.jpg";
    })
    (fetchurl {
      url =
        "https://images.squarespace-cdn.com/content/v1/5af35f78266c07d9fd3ae075/1530163620022-JYQYQF0GRY3XVJZXIZ7D/ke17ZwdGBToddI8pDm48kPRPfF7iGTQlN_HblE0-rw17gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iy8Rj2bPXFyaluz0PeKicNeOG44PLUr71pvuODVcFtV0YIapNWlU5y1sX93YwLcUg/Gibbon+Lake%2C+WY+1+by+MatthewBrandt.com?format=orig";
      sha256 = "1bv9l3nmsw542gmhdrpgp2zixwfn7rnpa6lry50lzi26gc0h29h2";
      name = "matthew-brandt-gibbon-lake.jpg";
    })
    (fetchurl {
      url =
        "https://images.squarespace-cdn.com/content/v1/5af35f78266c07d9fd3ae075/1530169450650-R56CYAQ452GGD9Z783EX/ke17ZwdGBToddI8pDm48kGEdLrJdqAeMSJz41xzDvnl7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iy8Rj2bPXFyaluz0PeKicNF9zhRDRVOFHrvSK2QoXbA_0gvHqAA-DZc3U0Z_zIy8g/Nymph+Lake%2C+WY+4A+by+MatthewBrandt.com?format=orig";
      sha256 = "0955025y4gqvdxd2y0shy3nnn1rvprj7c47z4rv8x511ywzzsv5k";
      name = "matthew-brandt-nymph-lake.jpg";
    })
    (fetchurl {
      url =
        "https://images.squarespace-cdn.com/content/v1/5af35f78266c07d9fd3ae075/1530170164787-1M0DSN9F3WTZ09J87TBW/ke17ZwdGBToddI8pDm48kGEdLrJdqAeMSJz41xzDvnl7gQa3H78H3Y0txjaiv_0fDoOvxcdMmMKkDsyUqMSsMWxHk725yiiHCCLfrh8O1z4YTzHvnKhyp6Da-NYroOW3ZGjoBKy3azqku80C789l0iy8Rj2bPXFyaluz0PeKicNF9zhRDRVOFHrvSK2QoXbA_0gvHqAA-DZc3U0Z_zIy8g/Sylvan+Lake%2C+CA+5+by+MatthewBrandt.com?format=orig";
      sha256 = "1n1a7879p381l01l1mj2axl68sj6nmdl9ns5j231yj3bdj271z9i";
      name = "matthew-brandt-sylvan-lake.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/65535/50326438771_f074f6e5b3_6k.jpg";
      sha256 = "0k5ijajwjpl7spiphksv29gd4albppvi0y8xg34jh192f57f7qlv";
      name = "anek-suwannaphoom-bankok-skyline.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50325570556_9b694e5834_o_d.jpg";
      sha256 = "1jrr857xbk0gyrqjgfhji3qw8zx80kvqc901sbv4k4dqq1q2iqma";
      name = "oskar-gunther-swiss-alps.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/48334391441_8a9dc9c1a0_o_d.jpg";
      sha256 = "1kqaavvran7dz27nh2lk0md2cl0jqskg5xrvk1wlncfw8pmm3v44";
      name = "apollo-11-buzz-aldrin-on-moon.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/48322614352_9c62f4d86f_o_d.jpg";
      sha256 = "1k3byav98yck8g617q7ffpadssv5yal563zmbyfi1h352vw1vx43";
      name = "apollo-11-earth.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/662/21926292752_753af505aa_o_d.jpg";
      sha256 = "1z3rna813j9s0car0j83zyx3xdpg24l7y01ivs5jpkl08hwzmzi9";
      name = "apollo-9-20e-as09-20-3057.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/762/21472225870_ac6ea12c7b_o_d.jpg";
      sha256 = "15ybvgy728gq2jx71pzqjdlcksraymb1b91c7b2zdl6k6p1w95sx";
      name = "apollo-11-as11-40-5866.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5797/21899770692_06e5cc7d7f_o_d.jpg";
      sha256 = "16i3g5v6v946ybvv5phqh1mk5mqcrn213slnxnv3cwksmm9dr37c";
      name = "apollo-9-as09-19-2999.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/667/21723747028_738cf82a92_o_d.jpg";
      sha256 = "1hy7lri301b8vziagp9xn8yp2k8n0xdi2hx8g04f3f4mfchxpqdv";
      name = "apollo-7-as07-3-1541.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/680/21723946818_9f78b1d456_o_d.jpg";
      sha256 = "19q8shbfqrclnasj1xviz2316pv9x24070wn4pyxcxkqs9ypc816";
      name = "apollo-9-as09-19-2922.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/565/21912158276_09c2e033a3_o_d.jpg";
      sha256 = "12fxsmwhyi509bj60mcxpp84nsqsdckxbmkb159vm6jr2ixc4v68";
      name = "apollo-9-as09-20-3097.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5705/21925846771_f0ca252ff4_o_d.jpg";
      sha256 = "1q4hi7760646bns3f65k4xb4svrf2js7b9hx4ic46skmrhv3y24r";
      name = "apollo-9-as09-21-3183.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/5618/21513738508_31c49c4f1a_o_d.jpg";
      sha256 = "1k5j361j6axjm44p8mwqcwvhk1a3172la9xc6zlxl6npp7sb6glx";
      name = "apollo-11-as11-36-5293.jpg";
    })
    (fetchurl {
      url = "https://live.staticflickr.com/765/21787592430_e7d821e30e_o_d.jpg";
      sha256 = "1b2z5j2sfz1zd72vya1qh1gg8dl7xz44sd2v5szrjs5g0bl04aqb";
      name = "apollo-13-as13-62-8929.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50251666453_0ec1cc9025_o_d.jpg";
      sha256 = "1ssjh2kvn0a185wd6vza0finz6m838p96sfp4a1iaha1ww1cmfjb";
      name = "hubble-ngc-2442.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50173806488_77746f607d_o_d.jpg";
      sha256 = "106xkmi8wnxs9hd7xb21xbmsgp19w4bzmhr8g6g6xpp9nswwxixd";
      name = "hubble-sunburst-arc.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/50174348192_6a4f4c1143_o_d.jpg";
      sha256 = "0nijlz4xi8wj7i98nn067w7gsna3dg4qgg3yx0kk6qjqdbhcwkkr";
      name = "hubble-ugc-2885.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49576856528_be4bd6e1f1_o_d.jpg";
      sha256 = "16r5f239v1dp31hnc36bh7290jrv4d75nji1712cysqbfq77b3dx";
      name = "hubble-westerlund-2.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49757380101_4e21a0b943_o_d.jpg";
      sha256 = "019d99ir6hc4qbn79f3kh2wrpbnkr9bh1mm3p1y9ya26kzpw7alc";
      name = "hubble-m82.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49577469242_0e03a1212e_o_d.jpg";
      sha256 = "0k29hnr0ymxqhsxm7iyl6gl5c096f3f421hdp37gwlk92pkdhlmx";
      name = "hubble-star-factory-30-doradus.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49229718218_c45cb73370_o_d.jpg";
      sha256 = "08y43s4m7ps0xahnx0i3n0rw3y6nlwxgrpph7x071b8dkndg9wqq";
      name = "nasa-caldwell-5.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49214609086_369f001abb_o_d.jpg";
      sha256 = "1rvmqj0vip4pgy9i2nshz3kisxhw3sj8ryh3ydha320kn8v0kxqp";
      name = "hubble-caldwell-103.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49210917523_a78a20b307_o_d.jpg";
      sha256 = "083i9kddyrk568pg29nkhz8fii0cwm2z2cmwm9bbplskijia0jsp";
      name = "hubble-ngc-4038-and-ngc-4039.jpg";
    })
    (fetchurl {
      url =
        "https://live.staticflickr.com/65535/49199725743_912e33e1f0_o_d.jpg";
      sha256 = "09vribwl4r6y9q0fihmpmy23hz5g4r03cdqz66i2jmylirya95r6";
      name = "hubble-caldwell-38.jpg";
    })
  ];

  dontUnpack = true;
  dontConfigure = true;
  buildPhase = ''
    mkdir -p "$out/share/wallpapers"
    for src in $srcs; do
      cp "$src" "$out/share/wallpapers/$(stripHash "$src")"
    done
  '';
  dontInstall = true;
  dontFixup = true;
}
