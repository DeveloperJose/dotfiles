#!/bin/bash
set -euo pipefail

# === Constants ===
NEOVIM_VERSION_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
NEOVIM_DIR="/opt/nvim-linux-x86_64"
CHEZMOI_REPO="git@github.com:developerjose/dotfiles.git"

# === Helper Functions ===

install_if_missing() {
	if ! dpkg -s "$1" &>/dev/null; then
		echo "Installing $1..."
		sudo apt install -y "$1"
	else
		echo "$1 already installed."
	fi
}

install_rust() {
	if command -v rustc &>/dev/null; then
		echo "Rust is already installed."
	else
		echo "Installing Rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
		# Add cargo to PATH for current session
		export PATH="$HOME/.cargo/bin:$PATH"
	fi
}

install_lazygit() {
	if command -v lazygit &>/dev/null; then
		echo "Lazygit already installed."
		return
	fi

	echo "Installing Lazygit..."
	local version
	version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')

	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
	tar -xzf lazygit.tar.gz lazygit
	sudo install lazygit /usr/local/bin/lazygit
	rm -f lazygit lazygit.tar.gz
}

install_neovim() {
	local installed_version=""
	local latest_version=""

	if command -v nvim &>/dev/null; then
		installed_version=$(nvim --version | head -n1 | grep -oP 'NVIM v\K\S+')
	fi

	latest_version=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name":\s*"\Kv[0-9.]+' | head -1)
	latest_version=${latest_version#v}

	if [[ -z "$installed_version" ]]; then
		echo "Neovim is not installed. Installing version $latest_version..."
	elif [[ "$installed_version" == "$latest_version" ]]; then
		echo "Neovim is up to date (version $installed_version). Skipping installation."
		return
	else
		echo "Updating Neovim from version $installed_version to $latest_version..."
	fi

	curl -LO "$NEOVIM_VERSION_URL"
	sudo rm -rf "$NEOVIM_DIR"
	sudo mkdir -p "$NEOVIM_DIR"
	sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
	rm -f nvim-linux-x86_64.tar.gz
	sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
}

install_chezmoi() {
	if command -v chezmoi &>/dev/null; then
		echo "chezmoi already installed. Skipping initialization to avoid overwriting local changes."
	else
		echo "Installing chezmoi..."
		sh -c "$(curl -fsLS get.chezmoi.io)"

		echo "Initializing chezmoi repo..."
		chezmoi init --apply "$CHEZMOI_REPO"
	fi
}

set_zsh_default() {
	if [ "$SHELL" != "$(which zsh)" ]; then
		echo "Setting Zsh as default shell..."
		sudo chsh -s "$(which zsh)" "$(whoami)"
	else
		echo "Zsh is already default shell."
	fi
}

install_powerlevel10k() {
	if [ ! -d "${HOME}/.powerlevel10k" ]; then
		echo "Cloning Powerlevel10k theme..."
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}/.powerlevel10k"
	else
		echo "Powerlevel10k already installed."
	fi
}

install_pnpm() {
	if ! command -v pnpm &>/dev/null; then
		echo "Installing pnpm..."
		curl -fsSL https://get.pnpm.io/install.sh | sh -
	else
		echo "pnpm already installed."
	fi
}

main() {
	echo "Updating package index..."
	sudo apt update

	echo "Installing packages..."
	for pkg in \
		zsh unzip git curl dos2unix tmux \
		xclip xsel ripgrep fzf fd-find libssl-dev \
		imagemagick python3 python3-venv python3-dev \
		build-essential make gcc pkg-config \
		ccze \
		nodejs npm; do
		install_if_missing "$pkg"
	done

	set_zsh_default
	install_powerlevel10k
	install_rust
	install_lazygit
	install_neovim
	install_chezmoi
	install_pnpm

	echo "✅ Initialization complete. You can re-run this script any time to sync state."
}

main "$@"
