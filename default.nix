{ host ? "laptop" }:
assert builtins.elem host [ "laptop" "desktop" "vps" ];
let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    system = if host == "vps" then "aarch64-linux" else "x86_64-linux";
  };
  home = import "${sources.home-manager}/modules" {
    inherit pkgs;
    configuration = ./home.nix;
    extraSpecialArgs = { inherit host; };
  };
  systemFiles = ./config + "/${host}/system";
in {
  home = home.activationPackage;
  config = home.config;
  system = if host == "laptop" then null else pkgs.writeShellScript "dotfiles-system-${host}" ''
    set -euo pipefail
    export PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.findutils ]}
    test "$EUID" -eq 0
    test "$(uname -n)" = "${if host == "desktop" then "arch-desktop" else "vps"}"
    cd ${systemFiles}
    while IFS= read -r -d "" file; do
      target="/''${file#./}"
      mode=644
      if test -x "$file"; then mode=755; fi
      if test ! -L "$target" && cmp -s "$file" "$target" && test "$(stat -c %a "$target")" = "$mode"; then
        continue
      fi
      install -D --backup=numbered -m "$mode" "$file" "$target"
    done < <(find . -type f -print0)
    ${if host == "vps" then "/usr/bin/systemctl daemon-reload" else
      "echo 'sudo grub-mkconfig -o /boot/grub/grub.cfg'"}
  '';
}
