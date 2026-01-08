function update --description 'Update system'
    sudo pacman -Syu
    
    set orphans (pacman -Qtdq)
    if test -n "$orphans"
        sudo pacman -Rns $orphans
    end
end
