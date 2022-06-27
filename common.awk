# -*- c-basic-offset: 4; indent-tabs-mode: nil -*-

BEGIN {
    FS = ",";

    maxpfx = 0;
    maxsfx = 0;
    maxname = 0;
    maxval = 0;

    entries = 0;
}

{
    ## Skip blanks and comments.
    if ($0 == "") next;
    if (match($0, /^\s*[#;]/)) next;

    if ($0 == "??") {
        pos = 1;
        delete CORES;
        delete PREFIXES;
        delete SUFFIXES;
        delete OFFSETS;
        delete FORMATS;
        next;
    }

    if ($1 == "?") {
        prefix = $2;
        suffix = $3;
        offset = strtonum($4);
        format = $5;
        if (format == "") format = "#x";
        if (length(prefix) > maxpfx) maxpfx = length(prefix);
        if (length(suffix) > maxsfx) maxsfx = length(suffix);
        PREFIXES[pos] = prefix;
        SUFFIXES[pos] = suffix;
        OFFSETS[pos] = offset;
        FORMATS[pos] = format;
        pos++;
        next;
    }

    if (substr($0, 1, 1) == "!") {
        delete CORES;
        delete PREFIXES;
        delete SUFFIXES;
        delete OFFSETS;
        delete FORMATS;
        $1 = substr($1, 2);
        for (i = 1; i <= NF; i += 3) {
            prefix = $i;
            offset = strtonum($(i + 1));
            format = $(i + 2);
            if (format == "") format = "#x";
            if (length(prefix) > maxpfx) maxpfx = length(prefix);

            pos = int((i + 2) / 3);
            PREFIXES[pos] = prefix;
            OFFSETS[pos] = offset;
            FORMATS[pos] = format;
        }
        next;
    }

    name = $1;
    if (name in CORES) {
        printf "Warning: %s line %d: ignored duplicate name %s\n",
            INPUT, FNR, name > "/dev/stderr";
        next;
    }
    CORES[name] = 1;


    if (length(name) > maxname) maxname = length(name);
    value = strtonum($2);
    for (i = 1; i <= length(PREFIXES); i++) {
        entries++;
        PREFIX[entries] = PREFIXES[i];
        SUFFIX[entries] = SUFFIXES[i];
        CORE[entries] = name;
        FORMAT[entries] = FORMATS[i];
        VALUE[entries] = value + OFFSETS[i];
        vallen = length(sprintf("%" FORMATS[i], VALUE[entries]));
        if (vallen > maxval) maxval = vallen;
    }
}
