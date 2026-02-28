# DevJ's Arch Linux dotfiles
This repo contains the dotfiles used for all my systems.

# Arch Setup
```bash
sudo pacman -S base-devel git chezmoi openssh nvim fish starship fastfetch lazygit tmux less \
    make unzip wget curl \
    fd ripgrep \
    bun python nodejs npm luarocks tree-sitter-cli rustup pnpm \
    docker docker-compose docker-buildx

chsh -s /usr/bin/fish

rustup default stable

cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

paru -S nvidia-container-toolkit php74 php74-mysql php74-xml php74-curl php74-zip php74-json php74-cli
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
