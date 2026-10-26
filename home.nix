{ config, lib, pkgs, host, ... }:
let
  common = {
    ".agents" = "common/.agents";
    ".bashrc" = "common/.bashrc";
    ".gitconfig" = "common/.gitconfig";
    ".tmux.conf" = "common/.tmux.conf";
    ".config/fish" = "common/.config/fish";
    ".config/nvim" = "common/.config/nvim";
    ".config/opencode" = "common/.config/opencode";
    ".config/pi" = "common/.config/pi";
    ".config/restic.env.example" = "common/.config/restic.env.example";
    ".config/starship.toml" = "common/.config/starship.toml";
    ".config/systemd" = "common/.config/systemd";
    ".local/bin/restic-backup" = "common/.local/bin/restic-backup";
  };
  extra = lib.optionalAttrs (host != "laptop") {
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
      "${config.home.homeDirectory}/dotfiles/config/${relative}";
  }) (common // extra);
}
