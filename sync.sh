#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ -z "$(git status --porcelain)" && "${DOTFILES_UPDATED:-0}" != 1 ]]; then
    git pull --ff-only
    exec env DOTFILES_UPDATED=1 bash ./sync.sh
fi
unset DOTFILES_UPDATED

case "$(uname -n)" in
    LAPTOP-0U1CQTBJ|arch-laptop|laptop) host=laptop ;;
    arch-desktop) host=desktop ;;
    vps) host=vps ;;
    *) echo "Unknown machine: $(uname -n)" >&2; exit 1 ;;
esac

export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:$PATH"
if ! command -v nix-build >/dev/null; then
    installer="$(mktemp)"
    curl -fsSL https://nixos.org/nix/install -o "$installer"
    sh "$installer" --daemon --no-modify-profile --no-channel-add
fi
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

activation="$(nix-build . -A home --argstr host "$host" --no-out-link)"
HOME_MANAGER_BACKUP_EXT="backup-$(date +%s)" "$activation/activate"

if [[ "$host" != laptop ]]; then
    mkdir -p "$HOME/.local/state/dotfiles"
    nix-build . -A system --argstr host "$host" -o "$HOME/.local/state/dotfiles/system"
    echo "sudo $HOME/.local/state/dotfiles/system"
fi

nvim --headless '+Lazy! restore' +qa
