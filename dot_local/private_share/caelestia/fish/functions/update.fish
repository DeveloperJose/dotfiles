function update --description 'Update system and caelestia configs'
    sudo pacman -Syu
    
    set orphans (pacman -Qtdq)
    if test -n "$orphans"
        sudo pacman -Rns $orphans
    end

    if test -d ~/.local/share/caelestia/
        cd ~/.local/share/caelestia/
        and git pull
        and cd -
    else
        echo "Directory ~/.local/share/caelestia/ not found."
    end
end
