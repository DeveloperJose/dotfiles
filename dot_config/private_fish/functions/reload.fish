function reload --description 'Reload Fish shell'
    source ~/.config/fish/config.fish
    notify-send "Config Reloaded" "Hyprland and Fish are up to date." --icon=view-refresh
end
