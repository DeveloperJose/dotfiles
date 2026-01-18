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

    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64
    set -gx EDITOR nvim
    set -gx TERM screen-256color

    # Added by LM Studio CLI (lms)
    set -gx PATH $PATH /home/devj/.lmstudio/bin
    # End of LM Studio CLI section

    # pnpm
    set -gx PNPM_HOME "/home/devj/.local/share/pnpm"
    if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
    end

    # pnpm end
    fastfetch
    starship init fish | source
end

