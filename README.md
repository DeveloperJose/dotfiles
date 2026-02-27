# DevJ's Arch Linux dotfiles
This repo contains the dotfiles used for all my systems.

# Arch Setup
```bash
sudo pacman -S base-devel git chezmoi openssh nvim fish starship fastfetch lazygit tmux \
    make unzip wget curl \
    fd ripgrep \
    python nodejs npm luarocks tree-sitter-cli rustup \
    docker docker-compose docker-buildx

chsh -s /usr/bin/fish

rustup default stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S nvidia-container-toolkit
```

# Window Manager Setup
## Wayland (Main Desktop/Laptop)
```bash
curl -fsSL https://install.danklinux.com | sh
```

## WSL (no WM, only TTY)
```bash
sudo pacman -S xclip xsel
```

# Sync dotfiles
```bash
chezmoi init --apply git@github.com:DeveloperJose/dotfiles.git
```
