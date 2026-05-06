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

export PATH="/opt/nvim/bin:$HOME/.local/bin:$HOME/bin:$PNPM_HOME:$PATH"
