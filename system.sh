#!/usr/bin/env bash
set -euo pipefail

if (($#)); then
    echo "Run sudo ./system.sh without arguments." >&2
    exit 2
fi
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f "$repo_dir/result-system/host" ]]; then
    echo "Run ./sync.sh as your normal user on the desktop or VPS first." >&2
    exit 1
fi
exec /usr/bin/python3 "$repo_dir/scripts/apply-system.py" "$repo_dir/result-system"
