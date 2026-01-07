# DevJ's Arch Linux dotfiles

## Init
```bash
sudo pacman -S git fish neovim hyprland
sudo pacman -S sane simple-scan brave-bin chezmoi lazygit thunar
sudo pacman -S npm nodejs ripgrep
sudo pacman -S composer
sudo pacman -S fd less wget curl nmap ntp numlockx openssh unzip wl-clipboard
sudo pacman -S texlive-latexrecommended texlive-latexextra texlive-mathscience texlive-binextra texlive-bibtexextra zathura biber

git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
~/.local/share/caelestia/install.fish

chezmoi init --apply git@github.com:DeveloperJose/dotfiles.git
```

