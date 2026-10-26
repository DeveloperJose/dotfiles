function ldir
    set dir "."
    if test -n "$argv[1]"
        set dir "$argv[1]"
    end
    ls -l "$dir" | grep "^d"
end