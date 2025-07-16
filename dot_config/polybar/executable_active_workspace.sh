#!/bin/bash

# Use i3-msg to get workspaces JSON and jq to find the focused workspace on this monitor
workspace=$(i3-msg -t get_workspaces | jq -r --arg mon "$MONITOR" '.[] | select(.output == $mon and .focused == true) | .name')

echo "$workspace"
