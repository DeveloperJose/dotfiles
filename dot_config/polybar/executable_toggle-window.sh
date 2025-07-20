#!/bin/bash

# Usage: toggle-window.sh <command> [process_name]
# Example: toggle-window.sh pavucontrol

cmd="$1"
process="${2:-$(basename "$1")}"

if pgrep -x "$process" >/dev/null; then
    pkill -x "$process"
else
    eval "$cmd &"
fi
