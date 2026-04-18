if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/bin
    fish_add_path /usr/sbin
    fish_add_path /sbin
    fish_add_path $HOME/.opencode/bin
    fish_add_path /usr/local/cuda/bin
    fish_add_path $HOME/.npm-global/bin
    fish_add_path $HOME/local-arch/ai/llama.cpp/build/bin
    fish_add_path /usr/lib/node_modules/.bin
    fish_add_path "$HOME/.bun/bin"
    fish_add_path $HOME/.cargo/bin

    set -gx DOCKER_BUILDKIT 1
    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64
    set -gx EDITOR nvim
    set -gx TERM screen-256color
    set --erase DISPLAY

    # --- SSH Agent ---
    if not set -q SSH_AUTH_SOCK; or test -z "$SSH_AUTH_SOCK"
        eval (ssh-agent -c)
    end
    for key in ~/.ssh/*
        if test -f "$key"
            and not string match -q "*.pub" "$key"
            and not string match -q ".pub" (string sub -l 4 (basename "$key"))
            and not string match -q "known_hosts*" "$key"
            and not string match -q "config" "$key"
            set -l key_fp (ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
            if not ssh-add -l 2>/dev/null | grep -q "$key_fp"
                ssh-add "$key" 2>/dev/null
            end
        end
    end

    # pnpm
    set -gx PNPM_HOME "/home/devj/.local/share/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
    end
    # pnpm end

    starship init fish | source

    fastfetch
end

