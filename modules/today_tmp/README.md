# today_tmp

So I usually have a folder like this at `~/Documents/tmp` or somewhere similar
to keep whatever garbage files I need to quickly write and maybe copy/paste to
a friend:

    .rw-r--r--  117 becca 24 Aug 16:30 default.nix
    .rw-r--r--  180 becca  2 Sep 14:25 euc.py
    .rwxr-xr-x  863 becca 15 Sep 21:02 flag.py
    .rw-r--r--  952 becca  7 Nov 20:46 gen_dict.py
    .rw-r--r--  320 becca 16 Sep 15:17 image-viewers.txt
    .rw-r--r-- 227k becca 29 Oct 22:01 nixos-services.txt
    .rwxr-xr-x   29 becca 14 Nov 17:17 q
    .rw-r--r-- 2.5k becca 15 Oct 15:23 response.md
    .rw-r--r--    0 becca 29 Sep 21:08 tmp.py
    .rw-r--r-- 1.1k becca  1 Sep 12:18 whatever.fish

But there's a few issues here. It's not clean, for one — files are never moved
out or deleted, so they just linger around getting older and older until I
accidentally reformat my hard drive. But at the same time, these files are
*juuuust* a bit too important for me to keep them on `/tmp`, so I don't really
*want* to delete them.

today_tmp, then, is a little program/service that makes a Git repo somewhere
you specify (e.g. `~/.config/today_tmp/repo`), creates a directory in it every
day (e.g. `./2020-11-18`), and creates a symlink from `~/Documents/tmp` to that
directory, so that every day I have a new little tmpdir to work in.

There's some convenience features — if there's anything changed, the service
makes a git commit, and it skips/deletes empty directories, so if you don't use
the tmp directory, you're not accumulating digital garbage anywhere. (This is
probably not an issue to anyone less neurotic than me.)

today_tmp also leaves a "previous" link in the current tmpdir to the previous
one, so if you want whatever you put in it yesterday or whenever you used it
last, it's in `~/Documents/tmp/prev` (symlinks are just files, so this also
builds up a linked list through the repository; as a result, you can look at
`~/Documents/tmp/prev/prev` for the second-to-last day you used the tmpdir).
