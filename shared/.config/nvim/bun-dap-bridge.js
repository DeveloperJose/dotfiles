#!/bin/bash
# Bun DAP Bridge - connects nvim-dap to Bun's WebSocket inspector
# Usage: node bun-dap-bridge.js <ws-url>

WS_URL="${1:-ws://localhost:6499/}"
DEBUGAdaptOR_PATH="$(dirname "$0")/dist/src/dapDebugServer.js"

if [ -f "$DEBUGAdaptOR_PATH" ]; then
  # Use the actual js-debug-adapter if available
  exec node "$DEBUGAdaptOR_PATH" "${2:-0}"
else
  echo "Bun DAP Bridge requires js-debug-adapter"
  exit 1
fi
