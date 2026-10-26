{ config, lib, ... }:
let
  link = relative: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/${relative}";
  };
in {
  # Live links preserve application-written state and keep ignored secrets out
  # of the Nix store. Home Manager owns the links; Git owns their source files.
  home.file = lib.mapAttrs (_: link) {
    ".agents" = "shared/.agents";
    ".bashrc" = "shared/.bashrc";
    ".gitconfig" = "shared/.gitconfig";
    ".tmux.conf" = "shared/.tmux.conf";
    ".config/fish" = "shared/.config/fish";
    ".config/nix" = "shared/.config/nix";
    ".config/nvim" = "shared/.config/nvim";
    ".config/opencode" = "shared/.config/opencode";
    ".config/pi" = "shared/.config/pi";
    ".config/restic.env.example" = "shared/.config/restic.env.example";
    ".config/starship.toml" = "shared/.config/starship.toml";
    ".config/systemd" = "shared/.config/systemd";
    ".local/bin/restic-backup" = "shared/.local/bin/restic-backup";
  };
}
