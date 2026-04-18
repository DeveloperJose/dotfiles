# DevJ's dotfiles
This repo contains the dotfiles used across my systems, managed via **GNU Stow**.

## 🛠️ Arch System Setup
First, install the core development and research stack:

```bash
sudo pacman -S base-devel git stow openssh nvim fish starship fastfetch lazygit tmux less \
    make unzip wget curl \
    fd ripgrep tree \
    bun python nodejs npm luarocks tree-sitter-cli rustup pnpm \
    docker docker-compose docker-buildx \
    ccache cmake cuda

# Set fish as default shell
chsh -s /usr/bin/fish

# Initialize Rust
rustup default stable

# Install AUR helper (paru)
cd /tmp && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si

# php7.4 + NVIDIA passthrough to docker
paru -S nvidia-container-toolkit php74 php74-mysql php74-xml php74-curl php74-zip php74-json php74-cli php74-tokenizer php74-phar php74-mbstring php74-simplexml php74-iconv php74-dom php74-xmlwriter

# Install Composer for PHP 7.4
wget https://raw.githubusercontent.com/composer/getcomposer.org/f3108f64b4e1c1ce6eb462b159956461592b3e3e/web/installer -O - -q | php74 -- --quiet
```

## 🖥️ Window Manager Setup
### Wayland (Desktop/Laptop)
```bash
curl -fsSL https://install.danklinux.com | sh
```

### WSL (TTY Only)
```bash
sudo pacman -S xclip xsel
```

## 🔄 Syncing Dotfiles
We use an environment-aware bootstrap script to handle symlinking. This script identifies the host and stows the appropriate configuration folders, moving any existing OS default files to a backup directory.

### 1. Clone the repository
```bash
git clone git@github.com:DeveloperJose/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the Bootstrap
```bash
chmod +x sync.sh
./sync.sh
```
