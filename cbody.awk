# -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

END {
    printf "const char *__riscos_%s(unsigned val)\n", NAME;
    printf "{\n";
    printf "  switch (val) {\n";
    printf "  default:\n";
    printf "    return 0;\n";

    for (i = 1; i <= entries; i++) {
        printf "  case %*" FORMAT[i] "\n", VALUE[i];
        printf "    return \"%s%s\";\n", PREFIX[i], CORE[i];
    }

    if (!system("test -r 'extras/" INPUT ".h'"))
        system("cat 'extras/" INPUT ".h'");

    printf "  }\n";
    printf "}\n";
}
