# Shared bash config for non-interactive agent shells.

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
