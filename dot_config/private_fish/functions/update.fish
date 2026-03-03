function update --description 'Full system update + Llama compilation'
    # 1. Update Mirrors
    # echo "--- Refreshing Mirrorlist ---"
    # sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

    # 2. Update Packages
    echo "--- Updating AUR and System Packages ---"
    paru -Syu --noconfirm

    # 3. Clean Orphans
    echo "--- Cleaning Orphans ---"
    set orphans (pacman -Qtdq)
    if test -n "$orphans"
        sudo pacman -Rns $orphans --noconfirm
    end

    # 4. Compile Llama
    echo "--- Running Local Llama Compilation ---"
    if test -f ~/local-arch/ai/compile_llama.sh
        # We use 'bash' to execute it in case it's not marked executable
        bash ~/local-arch/ai/compile_llama.sh
    else
        echo "Warning: compile_llama.sh not found at ~/local-arch/ai/"
    end

    # 5. Clean Cache
    echo "--- Trimming Package Cache ---"
    sudo paccache -rk2
end
