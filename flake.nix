{
  description = "Shared user packages for the laptop, desktop, and VPS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      home = system: username: hostModule:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home/common.nix
            hostModule
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
            }
          ];
        };
      systemFiles = system: machine: source:
        let pkgs = nixpkgs.legacyPackages.${system};
        in pkgs.runCommand "dotfiles-system-${machine}" { } ''
          mkdir -p "$out/files"
          cp -R ${source}/. "$out/files/"
          printf '%s\n' '${machine}' > "$out/host"
        '';
    in {
      homeConfigurations = {
        laptop = home "x86_64-linux" "devj" ./home/laptop.nix;
        arch-desktop = home "x86_64-linux" "devj" ./home/arch-desktop.nix;
        vps = home "aarch64-linux" "ubuntu" ./home/vps.nix;
      };
      packages = {
        x86_64-linux.arch-desktop-system = systemFiles
          "x86_64-linux" "arch-desktop" ./arch-desktop-system;
        aarch64-linux.vps-system = systemFiles
          "aarch64-linux" "vps" ./vps-system;
      };
    };
}
