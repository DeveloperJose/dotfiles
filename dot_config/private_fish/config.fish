if status is-interactive
    ### PATHS
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/bin
    fish_add_path /usr/sbin
    fish_add_path /sbin
    fish_add_path $HOME/.opencode/bin
    fish_add_path /usr/local/cuda/bin

    ### ENV VARIABLES
    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64
    set -gx EDITOR nvim
    set -gx TERM screen-256color

    # PNPM
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    fish_add_path "$PNPM_HOME"

    # FNM (Node Version Manager)
    if type -q fnm
        fnm env --use-on-cd | source
    end

    ### ALIASES
    alias update "sudo pacman -Syu"
    alias ll "ls -lh"
    alias gs "git status"
    alias gc "git commit"
    alias gco "git checkout"
    alias gst "git stash"
    alias gd "git diff"
    alias gdd "git -c diff.external=difft diff"
    alias lg "lazygit"
    alias chadd "chezmoi re-add"
    alias i3 "nvim ~/.config/i3/config"
    alias polybar "nvim ~/.config/polybar/config.ini"
    alias vpn "sudo openconnect --protocol=gp myvpn.utep.edu"

    # Complex commands
    alias updatelock "betterlockscreen -u ~/Pictures/Lockscreens/Horizontal.jpg -u ~/Pictures/Lockscreens/Vertical.jpg --fx dim --dim 10"
    alias disablelock "xset -dpms; and xset s off; and pkill xss-lock"
    alias logphp 'docker exec -it awbw-app sh -c "tail -F /var/log/php_errors.log" | ccze -A'

    ### FUNCTIONS

    # 1. ldir (Converted)
    function ldir
        set dir "."
        if test -n "$argv[1]"
            set dir "$argv[1]"
        end
        ls -l "$dir" | grep "^d"
    end

    # 2. Tmux AWBW
    function tmux_awbw
        if tmux has-session -t awbw 2>/dev/null; tmux kill-session -t awbw; end
        tmux new-session -d -s awbw -n nvim -c ~/local-debian/awbw
        tmux new-window -t awbw:2 -n shell -c ~/local-debian/awbw
        tmux new-window -t awbw:7 -n php -c ~/local-debian/awbw
        tmux send-keys -t awbw:7 'docker compose up app | ccze -A' C-m
        tmux new-window -t awbw:8 -n rust -c ~/local-debian/awbw
        tmux send-keys -t awbw:8 'docker compose up rust | ccze -A' C-m
        tmux new-window -t awbw:9 -n terrain -c ~/local-debian/awbw/public_html/terrain
        tmux attach-session -t awbw
    end

    # 3. Tmux Frontend
    function tmux_frontend
        if tmux has-session -t frontend 2>/dev/null; tmux kill-session -t frontend; end
        tmux new-session -d -s frontend -n nvim -c ~/local-debian/awbw/frontend
        tmux new-window -t frontend:2 -n shell -c ~/local-debian/awbw/frontend
        tmux new-window -t frontend:3 -n vue -c ~/local-debian/awbw/frontend
        tmux send-keys -t frontend:3 'pnpm run dev' C-m
        tmux attach-session -t frontend
    end

    # 4. Tmux NVIM
    function tmux_nvim
        if tmux has-session -t nvim 2>/dev/null; tmux kill-session -t nvim; end
        tmux new-session -d -s nvim -n nvim -c ~/.config/nvim
        tmux new-window -t nvim:2 -n shell -c ~/.config/nvim
        tmux attach-session -t nvim
    end

    # 5. Tmux Music
    function tmux_music
        if tmux has-session -t music 2>/dev/null; tmux kill-session -t music; end
        tmux new-session -d -s music -n nvim -c ~/local-debian/scripts
        tmux new-window -t music:2 -n shell -c ~/local-debian/scripts
        tmux new-window -t music:3 -n watch -c ~/local-debian/scripts
        tmux send-keys -t music:3 'pnpm watch:dev' C-m
        tmux new-window -t music:4 -n website -c ~/local-debian/website/
        tmux attach-session -t music
    end

    # 6. Tmux PhD
    function tmux_phd
        if tmux has-session -t phd 2>/dev/null; tmux kill-session -t phd; end
        tmux new-session -d -s phd -n nvim -c ~/local-debian/dissertation/
        tmux new-window -t phd:2 -n shell -c ~/local-debian/dissertation/
        tmux attach-session -t phd
    end

    fastfetch
end
