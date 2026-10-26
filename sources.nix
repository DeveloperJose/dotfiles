# 26.05
{
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/1f607aa79b6356ed45d3cd3c8079c196e79efa2c.tar.gz";
    sha256 = "1s7mrwxqalq59bqklyi3015kr2sy1kvf8a8s6d9ahchv7d3fn39j";
  };
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/24f2190587513b9c2f73db112a17844ae912d965.tar.gz";
    sha256 = "0z9ivs49j8n7r20kbyh86x59fl3izd90407djz678jfmwvp65pyp";
  };
}
