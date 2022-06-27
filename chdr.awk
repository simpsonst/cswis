# -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

END {
    printf "#ifndef __riscos_%s\n", NAME;
    printf "#define __riscos_%s\n\n", NAME;

    for (i = 1; i <= entries; i++) {
        entry = PREFIX[i] CORE[i] SUFFIX[i];
        printf "#if !defined(%s) || %s != %" FORMAT[i] "\n",
            entry, entry, VALUE[i];
        printf "#define %-*s %*" FORMAT[i] "\n",
            maxpfx + maxname + maxsfx, entry,
            maxval, VALUE[i];
        printf "#endif\n";
    }

    if (!system("test -r 'extras/" INPUT ".h'"))
        system("cat 'extras/" INPUT ".h'");

    printf "\n#endif\n";
}
