if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/bin
    fish_add_path /usr/sbin
    fish_add_path /sbin
    fish_add_path $HOME/.opencode/bin
    fish_add_path /usr/local/cuda/bin

    set -gx LD_LIBRARY_PATH $LD_LIBRARY_PATH /usr/local/cuda/lib64
    set -gx EDITOR nvim
    set -gx TERM screen-256color

    fastfetch
    starship init fish | source
end
