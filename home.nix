{ config, lib, pkgs, host, ... }:
let
  shared = {
    ".agents" = "shared/.agents";
    ".bashrc" = "shared/.bashrc";
    ".gitconfig" = "shared/.gitconfig";
    ".tmux.conf" = "shared/.tmux.conf";
    ".config/fish" = "shared/.config/fish";
    ".config/nvim" = "shared/.config/nvim";
    ".config/opencode" = "shared/.config/opencode";
    ".config/pi" = "shared/.config/pi";
    ".config/restic.env.example" = "shared/.config/restic.env.example";
    ".config/starship.toml" = "shared/.config/starship.toml";
    ".config/systemd" = "shared/.config/systemd";
    ".local/bin/restic-backup" = "shared/.local/bin/restic-backup";
  };
  extra = lib.optionalAttrs (host != "desktop") {
    ".config/environment.d/99-nix.conf" = "shared/.config/environment.d/99-nix.conf";
  } // lib.optionalAttrs (host != "laptop") {
    ".config/restic" = "${host}/.config/restic";
    ".ssh/config" = "${host}/.ssh/config";
  } // lib.optionalAttrs (host == "desktop") {
    ".config/DankMaterialShell" = "desktop/.config/DankMaterialShell";
    ".config/environment.d" = "desktop/.config/environment.d";
    ".config/foot" = "desktop/.config/foot";
    ".config/fuzzel" = "desktop/.config/fuzzel";
    ".config/niri" = "desktop/.config/niri";
  };
in {
  home.username = if host == "vps" then "ubuntu" else "devj";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  systemd.user.enable = false;
  xdg.mime.enable = false;

  home.packages = with pkgs; [
    fastfetch fd git htop jq lazygit less neovim ripgrep rsync
    starship tmux tree tree-sitter unzip wget zoxide
  ];

  home.file = lib.mapAttrs (_: relative: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/${relative}";
  }) (shared // extra);
}
