# Shared bash config for non-interactive agent shells.

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

export PNPM_HOME="$HOME/.local/share/pnpm"
for NODE_BIN in "$PNPM_HOME"/nodejs/*/bin; do
  if [ -d "$NODE_BIN" ]; then
    export PATH="$NODE_BIN:$PATH"
  fi
done

NPM_PREFIX="$(npm config get prefix 2>/dev/null || true)"
if [ -n "$NPM_PREFIX" ]; then
  export PATH="$NPM_PREFIX/bin:$PATH"
fi

export PI_CODING_AGENT_DIR="$HOME/.config/pi"
export PATH="/opt/nvim/bin:$HOME/.local/bin:$HOME/bin:$PNPM_HOME/bin:$PNPM_HOME:$PATH"


# Added by Antigravity CLI installer
export PATH="/home/devj/.local/bin:$PATH"

# Load Nix without installer edits to this shared file. Its tools take
# precedence over older native or /opt copies during the migration.
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi
for NIX_BIN in /nix/var/nix/profiles/default/bin "$HOME/.nix-profile/bin" "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile/bin"; do
  if [ -d "$NIX_BIN" ]; then
    export PATH="$NIX_BIN:$PATH"
  fi
done
unset NIX_BIN
