set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -l base_paths /opt/nvim/bin "$HOME/.local/bin" "$HOME/bin"
for node_bin in $PNPM_HOME/nodejs/*/bin
    if test -d "$node_bin"
        set -a base_paths "$node_bin"
    end
end
if type -q npm
    set -l npm_prefix (npm config get prefix 2>/dev/null)
    if test -n "$npm_prefix"
        set -a base_paths "$npm_prefix/bin"
    end
end
set -a base_paths $PNPM_HOME
for path_entry in $base_paths
    set -gx PATH (string match -v -e $path_entry $PATH)
end
set -gx PATH $base_paths $PATH

if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.opencode/bin
    fish_add_path /usr/local/cuda/bin
    fish_add_path $HOME/.npm-global/bin
    fish_add_path $HOME/local-arch/ai/llama.cpp/build/bin
    fish_add_path /usr/lib/node_modules/.bin
    fish_add_path $HOME/.cargo/bin
    set -gx PATH (string match -v -e /sbin $PATH | string match -v -e /usr/sbin)

    set -gx DOCKER_BUILDKIT 1
    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64
    set -gx EDITOR nvim
    set -gx TERM screen-256color
    set --erase DISPLAY

    # --- SSH Agent ---
    set -l ssh_agent_socket "$XDG_RUNTIME_DIR/ssh-agent.socket"
    if test -z "$XDG_RUNTIME_DIR"
        set ssh_agent_socket "/tmp/ssh-agent-$USER.sock"
    end

    if not set -q SSH_AUTH_SOCK; or test -z "$SSH_AUTH_SOCK"
        set -gx SSH_AUTH_SOCK "$ssh_agent_socket"
    end

    if test "$SSH_AUTH_SOCK" = "$ssh_agent_socket"
        ssh-add -l >/dev/null 2>&1
        if test $status -eq 2
            command rm -f "$SSH_AUTH_SOCK"
            eval (ssh-agent -c -a "$SSH_AUTH_SOCK")
        end
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

    if type -q fastfetch
        fastfetch
    end

    if type -q starship
        starship init fish | source
    end
end
