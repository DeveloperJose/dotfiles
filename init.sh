#!/bin/bash

#!/bin/bash
set -euo pipefail

# === Constants ===
NEOVIM_VERSION_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
NEOVIM_DIR="/opt/nvim-linux-x86_64"
CHEZMOI_USER="developerjose"

# === Helper Functions ===
install_if_missing() {
  if ! dpkg -s "$1" &>/dev/null; then
    echo "Installing $1..."
    sudo apt install -y "$1"
  else
    echo "$1 already installed."
  fi
}

echo "Updating package index..."
sudo apt update

# === Core Tools ===
echo "Installing essential tools..."
for pkg in zsh unzip git curl python3-venv make gcc ripgrep xclip \
           nodejs npm php php-mysql php7.4 php7.4-mysql; do
  install_if_missing "$pkg"
done

# === Zsh & Powerlevel10k ===
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting Zsh as default shell..."
  chsh -s "$(which zsh)"
fi

if [ ! -d ~/.powerlevel10k ]; then
  echo "Cloning Powerlevel10k theme..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
else
  echo "Powerlevel10k already installed."
fi

# === Lazygit ===
if ! command -v lazygit &>/dev/null; then
  echo "Installing Lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \
    grep -Po '"tag_name": *"v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
  rm -f lazygit lazygit.tar.gz
else
  echo "Lazygit already installed."
fi

# === Python uv ===
if ! command -v uv &>/dev/null; then
  echo "Installing Python uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

# === Neovim ===
if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -n1)" != *"NVIM v"* ]]; then
  echo "Installing Neovim..."
  curl -LO "$NEOVIM_VERSION_URL"
  sudo rm -rf "$NEOVIM_DIR"
  sudo mkdir -p "$NEOVIM_DIR"
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm -f nvim-linux-x86_64.tar.gz
  sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
else
  echo "Neovim already installed."
fi

# === Chezmoi ===
if ! command -v chezmoi &>/dev/null; then
  echo "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$CHEZMOI_USER"
else
  echo "chezmoi already installed. Applying dotfiles..."
  chezmoi apply
fi

echo "✅ Initialization complete. You can re-run this script any time to sync state."


#
# sudo apt update 
#
# # My tools
# sudo apt install -y zsh unzip git curl python3-venv
#
# # Neovim prereqs
# sudo apt install -y make gcc ripgrep xclip 
#
# # AWBW tools
# sudo apt install -y nodejs npm php php-mysql php7.4 php7.4-mysql
#
# # Set-up Zsh
# chsh -s $(which zsh)
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
#
# # Set-up Lazygit
# LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
# curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
# tar xf lazygit.tar.gz lazygit
# sudo install lazygit -D -t /usr/local/bin/
#
# # Set-up Python uv
# curl -LsSf https://astral.sh/uv/install.sh | sh
# echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
# echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
#
# # Now we install nvim
# curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
# sudo rm -rf /opt/nvim-linux-x86_64
# sudo mkdir -p /opt/nvim-linux-x86_64
# sudo chmod a+rX /opt/nvim-linux-x86_64
# sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
#
# # make it available in /usr/local/bin, distro installs to /usr/bin
# sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/
#
# # Chezmoi
# sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply developerjose
