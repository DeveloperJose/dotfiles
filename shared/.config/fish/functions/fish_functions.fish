
function ll
  ls -lh $argv
end

function gs
  git status $argv
end

function gc
  git commit $argv
end

function gco
  git checkout $argv
end

function gst
  git stash $argv
end

function gd
  git diff $argv
end

function gdd
  git -c diff.external=difft diff $argv
end

function lg
  lazygit $argv
end

function ldir
    set dir "."
    if test -n "$argv[1]"
        set dir "$argv[1]"
    end
    ls -l "$dir" | grep "^d"
end
