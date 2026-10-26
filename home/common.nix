{ pkgs, ... }:
{
  imports = [ ./files.nix ];

  # Compatibility baseline for Home Manager state, not a package version pin.
  # Package versions come from flake.lock.
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  # Existing service files are linked explicitly; don't generate extra units.
  systemd.user.enable = false;
  xdg.mime.enable = false;

  # Fish remains the native login shell;
  # OpenSSH, compilers, Docker, drivers, and other system tools stay native.
  home.packages = with pkgs; [
    fastfetch
    fd
    git
    htop
    jq
    lazygit
    less
    neovim
    ripgrep
    rsync
    starship
    tmux
    tree
    tree-sitter
    unzip
    wget
    zoxide
  ];
}
