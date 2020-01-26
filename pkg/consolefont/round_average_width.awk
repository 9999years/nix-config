#! /usr/bin/env -S awk -f

# Rounds the 'AVERAGE_WIDTH' field in a BDF font file to the nearest 10, to
# placate the incredibly whiny `bdf2psf` script.

# Rounds its argument to the nearest 10. Defined for positive numbers only.
function round10(x)
{
    scale = 10
    x /= scale
    int_part = int(x)
    frac_part = x - int_part
    if (frac_part >= .5)
        int_part += 1
    return scale * int_part
}

{
    if ($1 == "AVERAGE_WIDTH") {
        print $1, round10($2)
    } else {
        print $0
    }
}
