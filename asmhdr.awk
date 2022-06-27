# -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

END {
    for (i = 1; i <= entries; i++) {
        printf "%-*s * %*" FORMAT[i] "\n",
            maxpfx + maxname + maxsfx, PREFIX[i] CORE[i] SUFFIX[i],
            maxval, VALUE[i];
    }

    printf "\n\n\n\tEND\n";
}
