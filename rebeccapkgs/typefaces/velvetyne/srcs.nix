{ fetchzip, fetchFromGitLab, fetchFromGitHub }: [
  (fetchFromGitLab {
    name = "velvetyne-Avara";
    owner = "velvetyne";
    repo = "Avara";
    rev = "cb655944d819ff3636e35bc58407e2b30b36e6fe";
    sha256 = "0prh207as83md0hqych3hvzlvwck2k5hcy6mw531bjgacmlv731r";
  })
  (fetchFromGitLab {
    name = "velvetyne-backout";
    owner = "velvetyne";
    repo = "backout";
    rev = "3be76e8d9698905cf12381d2ae2cd9333c22b713";
    sha256 = "0gzg6wvycl3a3zr1dx0rnv4yf6cjzva1pbrw2r04hvpkj7lb54pd";
  })
  (fetchFromGitHub {
    name = "velvetyne-BilboINC";
    owner = "velvetyne";
    repo = "BilboINC";
    rev = "29927408a5b95cf05266fe36b4502f44fca593d2";
    sha256 = "1dpcac3lkzkqhp4q94ihvkpwkvfh9mb9rlm6s1ihm0xljz7a23hf";
  })
  (fetchzip {
    name = "velvetyne-bizmeud";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/bizmeud.zip";
    sha256 = "1wnrnfm5x7f96rsl63xf5mh44q7jxjxilds7vm8scmhdmhw1rcc8";
  })
  (fetchzip {
    name = "velvetyne-blocus";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/blocus.zip";
    sha256 = "112wrc06rdld4z81lz5gsb69nzaz6bc59f6fi7lris7pv5cmnfri";
  })
  (fetchFromGitHub {
    name = "velvetyne-BluuNext";
    owner = "velvetyne";
    repo = "BluuNext";
    rev = "a1d39f03faef4288ed99dca9f9a757b30e0b2627";
    sha256 = "19jwdypydhxvprm4c2dvhbviawx4kn1p65a4094wcldwfx905fnw";
  })
  (fetchzip {
    name = "velvetyne-boeticher";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/boeticher.zip";
    sha256 = "1qgrjj82q9hwz5xc42a5mw0c4x8hxd0hw45pyiacmjjjyj5y8hkl";
  })
  (fetchFromGitLab {
    name = "velvetyne-cantique";
    owner = "velvetyne";
    repo = "cantique";
    rev = "ff74dccdf7af6c3c4d1af70f44732ef87d75ce61";
    sha256 = "0d4haig44yr4lck7zvhzhjh7qmyawxg1mrdqcdawp51c4kmjx3pg";
  })
  (fetchzip {
    name = "velvetyne-chaumont";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/chaumont.zip";
    sha256 = "14apd1maldlcla8dkbi6h9n99ymbmm74rqxrc01cl944bwppbxam";
  })
  (fetchFromGitLab {
    name = "Clarasambot-cirruscumulus";
    owner = "Clarasambot";
    repo = "cirruscumulus";
    rev = "f4a5673e51959e55fc488df00a9f3d638a850677";
    sha256 = "0bn74b8rr2cl5y5nkcdq736c6qbvy1a6l5j6k3clx5qfgbhdchd1";
  })
  (fetchFromGitHub {
    name = "martindesinde-Combat";
    owner = "martindesinde";
    repo = "Combat";
    rev = "67659793e45764ed8faa242a4d5654fc6cf40649";
    sha256 = "1bk042fgdb9xrp20zx8jvc5rgqb3zgccx97xnlic0v7zrcm5080g";
  })
  (fetchFromGitHub {
    name = "velvetyne-Commune-Nuit-Debout";
    owner = "velvetyne";
    repo = "Commune-Nuit-Debout";
    rev = "260989f3fef5ff3189603b17280dc40ba8e1c097";
    sha256 = "0xrg6z29223yj5khzhi00gnkgf0ywlbiygy53mfsi8zhjz4d85yz";
  })
  (fetchFromGitLab {
    name = "velvetyne-compagnon";
    owner = "velvetyne";
    repo = "compagnon";
    rev = "4f2344df5adb6eaf9ffd9215c5406c0729fb7aa1";
    sha256 = "1rm1v9yd2wv9m8aafs9gz9m93nfsrj5d0iix4iqbrdk38rsgwm07";
  })
  (fetchFromGitHub {
    name = "velvetyne-Daubenton";
    owner = "velvetyne";
    repo = "Daubenton";
    rev = "71206c4d747b9d37db7b942deff8ed5e54b2f617";
    sha256 = "07bd8k3hvk1c2n6jjy8az1pnbg5s6qdfxhvallix8j4x5gv68p00";
  })
  (fetchzip {
    name = "velvetyne-fengardo-neue";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/FengardoNeue.zip";
    sha256 = "1gxhwbmwswrl0yd1jxrqdsyxs059ac78a09gz7p7hh1girk3xa2s";
  })
  (fetchFromGitLab {
    name = "velvetyne-format-1452";
    owner = "velvetyne";
    repo = "format-1452";
    rev = "4af715b8a873139975d2651f0e316604508635ff";
    sha256 = "0298xv8ndqi508adp21mcxwf15mqayqikrzb13zy2r9w7fwfnj0q";
  })
  (fetchzip {
    name = "velvetyne-grotesk";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/grotesk.zip";
    sha256 = "0f1xgiqkrdg53phbwbwfks8afpprk6x2h5nifxn2f4kkp0dzld83";
  })
  (fetchzip {
    name = "velvetyne-gulax";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/gulax.zip";
    sha256 = "0rgxs1iq4arxf7c4q151pf18b2dcrw4f4nc8gjkvl54b33zjx5qi";
  })
  (fetchFromGitHub {
    name = "velvetyne-Hangul";
    owner = "velvetyne";
    repo = "Hangul";
    rev = "3f04defa470d19c76d82816aaf4ab18ce4c9f23a";
    sha256 = "1rw1y39nykjqj5nf2f7q7sbvp52gkp32wk3lhmqpivdxdrycznxl";
  })
  (fetchFromGitLab {
    name = "velvetyne-Happy-Times-at-the-IKOB";
    owner = "velvetyne";
    repo = "Happy-Times-at-the-IKOB";
    rev = "0fc4cf5da8c67bd19c3b88b20f233a3564516427";
    sha256 = "07mjhgqsi0qj6gvqgh5vh6ij840gkxd7rdw0wx2sznbdl811ny1k";
  })
  (fetchFromGitLab {
    name = "StudioTriple-Hyper-Scrypt";
    owner = "StudioTriple";
    repo = "Hyper-Scrypt";
    rev = "d7c8bc9029a886755095de92d3509ecb016ce788";
    sha256 = "1swxk5qhr3g9l8kkbpahx7l15f8jk1q8i6k35ax846dzs03l1n9q";
  })
  (fetchFromGitLab {
    name = "velvetyne-kaerukaeru";
    owner = "velvetyne";
    repo = "kaerukaeru";
    rev = "dae804908ffb9249af2c4ee0b65a4a9084620de5";
    sha256 = "0f5myczwv35ly5g3xxdw98aak9gxdy0x1fa95bvl87l6cig4qc9p";
  })
  (fetchFromGitLab {
    name = "phantomfoundry-karrik_fonts";
    owner = "phantomfoundry";
    repo = "karrik_fonts";
    rev = "42ae96dcdfdd75b883d4d56a783c337f818f6651";
    sha256 = "0w3jprghkasyrn4gi9qpmdngrsqfr8hdfdr7l52j87mk26c859gd";
  })
  (fetchFromGitLab {
    name = "velvetyne-lack";
    owner = "velvetyne";
    repo = "lack";
    rev = "80e730e1f5f550a48cddcb1521f8a5767ffe7917";
    sha256 = "0l4ap6n0j9lz41c87v02lkzhrzm6bf832vhk3njw1kblxb1gcah9";
  })
  (fetchFromGitLab {
    name = "velvetyne-murmure";
    owner = "velvetyne";
    repo = "murmure";
    rev = "73612466088bf819a430364393e70dd06071ed3e";
    sha256 = "1vbrdzkwa2cj7gwgr1nswzivigc7fdpyycj4bi9g26hd6jjcd2cj";
  })
  (fetchzip {
    name = "velvetyne-lineal";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/lineal.zip";
    sha256 = "1kdf5g3jplcnz5dgvi7jcwg103kwk5gxkizyrbyzwf7nc7aippy3";
  })
  (fetchFromGitHub {
    name = "velvetyne-Lment_";
    owner = "velvetyne";
    repo = "Lment_";
    rev = "5c461b495699ad3d1324ad3d1f307338a24e27f5";
    sha256 = "0px5fi25xd8rs9cwb5d9siplzqznqcr40b5wn3aprlqc7nyf61qw";
  })
  (fetchzip {
    name = "velvetyne-mainz";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/mainz.zip";
    sha256 = "09923yvy95dhij8qz32qy8pjkb015khjxiizx5h97k4a404gndkw";
  })
  (fetchFromGitLab {
    name = "velvetyne-Mess";
    owner = "velvetyne";
    repo = "Mess";
    rev = "c0ec947a54d664c2b08bd5e9a7b7baf877a73423";
    sha256 = "0k2gplsq837gxja2lbnqvv8pwx3yflnfp8gnm1ynmh4sa1nmp54i";
  })
  (fetchFromGitLab {
    name = "StudioTriple-Millimetre";
    owner = "StudioTriple";
    repo = "Millimetre";
    rev = "2553b3a2a9e0339ea758938b493a0b23ed78ff5c";
    sha256 = "1hlg059x72fnhlagm3d0rcizara0aj2pb8ahmd26c2pcvn0zkhzx";
  })
  (fetchFromGitHub {
    name = "ronotypo-Minipax";
    owner = "ronotypo";
    repo = "Minipax";
    rev = "ca9a4d9fd4d120e646bc69b4f36b7f90335d00a1";
    sha256 = "0ds7h4mkm5yl0pia5zlq25dxxhkhg85ynadxg99csv0bv2fdlnd1";
  })
  (fetchzip {
    name = "velvetyne-mr-pixel";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/mr_pixel.zip";
    sha256 = "1ml7qb72zhdb784pvdjjd0gav921yw4kjhc80vj9pj61yjsx3668";
  })
  (fetchzip {
    name = "velvetyne-mixo";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/mixo.zip";
    sha256 = "0wxz9gvp645rlgw5bv91rpi6g0nwyccx7kii0ddzj347814bsaxd";
  })
  (fetchzip {
    name = "velvetyne-mono";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/mono.zip";
    sha256 = "1mmpqzh4zqvl25znr68vxljc08h878cb55xaqakd0l2fj50j7cgs";
  })
  (fetchzip {
    name = "velvetyne-montchauve";
    curlOpts = "-H @${./curl-headers.txt}";
    stripRoot = false;
    url = "http://velvetyne.fr/archives/fonts/montchauve.zip";
    sha256 = "06vcy0d0qg8d1315rs4n46a3apyl5qn3pbvdb03hpcx08v2w4x7k";
  })
  (fetchFromGitLab {
    name = "velvetyne-mourier";
    owner = "velvetyne";
    repo = "mourier";
    rev = "02c6e2d3aa23b3b8b625f50b7a912baa02e055f5";
    sha256 = "19na95101ky85knkz7qv7v6225ghy714nhsq8j2vb3mgv6qdkrd4";
  })
  (fetchFromGitLab {
    name = "arielmartinperez-ouroboros";
    owner = "arielmartinperez";
    repo = "ouroboros";
    rev = "0f4265798d00d63c49ca3e17b02616b63f08ec1d";
    sha256 = "0p16fqhiik7zka3fkirnv5aykrg2ky8vz5ymnmh2bq9yaivr7jh0";
  })
  (fetchFromGitLab {
    name = "StudioTriple-pilowlava";
    owner = "StudioTriple";
    repo = "pilowlava";
    rev = "78ee860971cf929a90d3080b324d7db1655bcfb2";
    sha256 = "1iyna2fr42qifg35s08nir05vysi5fl8yc3v2kdf0rk6lkx3qbr0";
  })
  (fetchFromGitHub {
    name = "velvetyne-resistance-generale";
    owner = "velvetyne";
    repo = "resistance-generale";
    rev = "b45a061aa8e7f1fdd783fc3170438bf7238ca656";
    sha256 = "032cl77fx72y0d16rglbanm1mrfv20r7a18l6qwzm59l1k45wd86";
  })
  (fetchFromGitHub {
    name = "velvetyne-runic";
    owner = "velvetyne";
    repo = "runic";
    rev = "51ed441fb970b7e536fd3675163b7b43bde96d99";
    sha256 = "10d2rg6v7vm583wqbn80y395wvnggvw3pi9k5yxx81kqb69mh9sk";
  })
  (fetchFromGitHub {
    name = "velvetyne-saintjean";
    owner = "velvetyne";
    repo = "saintjean";
    rev = "a5c7a35d478db8da7ecec2085fb47879383708d5";
    sha256 = "05wlsir1yi88p644963jv5bvw7awh2s2fys53kmsvsv33gp7ng3d";
  })
  (fetchFromGitHub {
    name = "CollectifWech-Savate";
    owner = "CollectifWech";
    repo = "Savate";
    rev = "2bfdbe9b123ff7a371cb21720255b5484ab3a83f";
    sha256 = "14qba033jcah3bs67r2sg3hw3vqvmi8xqshhck9jphf6bh757myw";
  })
  (fetchFromGitLab {
    name = "StudioTriple-Solide-Mirage";
    owner = "StudioTriple";
    repo = "Solide-Mirage";
    rev = "307534716e9b890f27dd0530ef1256cbfd75006a";
    sha256 = "1c90afhs8naipl9fflk7w02bcaqz3klhihxbqj4nbx6l3w9rj2y5";
  })
  (fetchFromGitHub {
    name = "velvetyne-Sporting-Grotesque";
    owner = "velvetyne";
    repo = "Sporting-Grotesque";
    rev = "53c55c34b272b91b26cc2ab128e2d563eee683e6";
    sha256 = "02s0kzxjixa04mg3n9z9c7d1k77g4gj1wqg8l7vm8lm547mywycn";
  })
  (fetchFromGitHub {
    name = "raphaelbastide-steps-mono";
    owner = "raphaelbastide";
    repo = "steps-mono";
    rev = "c090a793d63da17a87d8abcde0c71b58b07ee74b";
    sha256 = "0i1q6i01lvdz68ssl99000zsk7hhmhfgb84jqjalf3546bspckza";
  })
  (fetchFromGitHub {
    name = "raphaelbastide-Terminal-Grotesque";
    owner = "raphaelbastide";
    repo = "Terminal-Grotesque";
    rev = "a64aef8b591909c8c365a206c33e60464d801ec7";
    sha256 = "1zics02wyinnqjslip7h76ydacwck850wkpf5m1dxwb16z0x4hnz";
  })
  (fetchFromGitHub {
    name = "jckfa-tinyfonts";
    owner = "jckfa";
    repo = "tinyfonts";
    rev = "02bdbe0b915cc49d131bed0f1991471e835bf522";
    sha256 = "0hp9q3c1ibf01ik4af348n0dcw9himpj21q1c1zgl3x1wq9gf32b";
  })
  (fetchFromGitHub {
    name = "velvetyne-Trickster";
    owner = "velvetyne";
    repo = "Trickster";
    rev = "751b1fa5fd5293614d0eb4df4962ec195fa243ab";
    sha256 = "1bjk7pz8lvkcx19wy0p8p1pj4xv0mvcspyf6vqg7a0q54l1vky0s";
  })
  (fetchFromGitHub {
    name = "ohpla-typefesse";
    owner = "ohpla";
    repo = "typefesse";
    rev = "3a1d99ace34398547315e55dafb7263310148350";
    sha256 = "1ixgmcrnmyqggjgwh8ir39cjwzcqc1sikmkwwdpacxxr4kmgzchg";
  })
  (fetchFromGitLab {
    name = "velvetyne-vg5000";
    owner = "velvetyne";
    repo = "vg5000";
    rev = "e4eeaed973f75fd5bafe2c69de60e8ad0f710f58";
    sha256 = "18dbay1yfy59zmis1iwpd55mjx713pjn71rid0wpa90kjdd0x8x6";
  })
  (fetchFromGitHub {
    name = "velvetyne-Victorianna";
    owner = "velvetyne";
    repo = "Victorianna";
    rev = "4f23f75a6de0e8a6389e6d48fd642eed24c871ed";
    sha256 = "0aanxcngcky4ybzg4d8ik8m1rslwnm6vz6wdzzh8d1r261w0cd68";
  })
]
