 #!/usr/bin/awk -f

{
    lines[NR] = $0
    if ($0 ~ /^[ \t]*[0-9]+([ \t]|$)/) {
        num = $1 + 0
        if (num > 0) {
            exists[num] = 1
            sub(/^[ \t]*[0-9]+[ \t]*/, "", $0)
            original[num] = $0
            order[++cnt] = num
        }
    }
}

END {
    for (i=1; i<cnt; i++)
        for (j=i+1; j<=cnt; j++)
            if (order[i] > order[j]) {
                t = order[i]; order[i] = order[j]; order[j] = t
            }

    for (i=1; i<=cnt; i++) {
        ln = order[i]
        stmt = original[ln]

        gsub(/\b(GOTO|GOSUB)[ \t]+([0-9]+)/, "&L\\2", stmt)
        gsub(/\bTHEN[ \t]+([0-9]+)/, "THEN L\\1", stmt)
        gsub(/\bTHEN[ \t]+GOTO[ \t]+([0-9]+)/, "THEN GOTO L\\1", stmt)

        printf "L%d: %s\n", ln, stmt

        while (match(stmt, /[0-9]+/)) {
            tgt = substr(stmt, RSTART, RLENGTH) + 0
            if (!(tgt in exists))
                print "Warning: missing line" tgt > "/dev/stderr"
            stmt = substr(stmt, RSTART + RLENGTH)
        }
    }

    for (i=1; i<=NR; i++)
        if (lines[i] && lines[i] !~ /^[ \t]*[0-9]+/)
            print lines[i]
}
