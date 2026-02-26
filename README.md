# DevJ's Arch Linux dotfiles

## Init
```bash
# Arch
sudo pacman -S base-devel git chezmoi openssh nvim \
    make unzip wget curl \
    fd ripgrep \
    python nodejs npm luarocks tree-sitter-cli

# X11
sudo pacman -S xclip xsel

# Wayland
curl -fsSL https://install.danklinux.com | sh

# Sync dotfiles
chezmoi init --apply git@github.com:DeveloperJose/dotfiles.git
```

