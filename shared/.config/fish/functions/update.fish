function update --description 'Full system update + Llama compilation'
    # 1. Update Mirrors
    # echo "--- Refreshing Mirrorlist ---"
    # sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # 2. Update Packages
    echo "--- Updating AUR and System Packages ---"
    paru -Syu --noconfirm

    # Compile Llama
    echo "--- Running Local Llama Compilation ---"
    if test -f ~/local-arch/ai/compile-llama.sh
        # We use 'bash' to execute it in case it's not marked executable
        bash ~/local-arch/ai/compile-llama.sh
    else
        echo "Warning: compile-llama.sh not found at ~/local-arch/ai/"
    end

    # Clean Cache
    echo "--- Trimming Package Cache ---"
    sudo paccache -rk2
end
