# DevJ's Neovim Configuration
Based on Kickstart.nvim

## Installation (Debian)
```sh

# Zsh
sudo apt install zsh
chsh -s $(which zsh)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $developerjose

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# nvim programming tools
sudo apt install make gcc ripgrep unzip git xclip curl
sudo apt install python3-venv nodejs npm php

# Python uv
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc

# Now we install nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo mkdir -p /opt/nvim-linux-x86_64
sudo chmod a+rX /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

# make it available in /usr/local/bin, distro installs to /usr/bin
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/

git clone git@github.com:DeveloperJose/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```
