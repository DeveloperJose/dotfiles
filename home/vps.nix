{ config, lib, ... }:
let
  link = relative: {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/vps/${relative}";
  };
in {
  home.file = lib.mapAttrs (_: link) {
    ".config/restic" = ".config/restic";
    ".ssh/config" = ".ssh/config";
  };
}
