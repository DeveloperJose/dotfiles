{ config, lib, ... }:
let
  link = relative: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/arch-desktop/${relative}";
  };
in {
  home.file = lib.mapAttrs (_: link) {
    ".config/DankMaterialShell" = ".config/DankMaterialShell";
    ".config/environment.d" = ".config/environment.d";
    ".config/foot" = ".config/foot";
    ".config/fuzzel" = ".config/fuzzel";
    ".config/niri" = ".config/niri";
    ".config/restic" = ".config/restic";
    ".ssh/config" = ".ssh/config";
  };
}
