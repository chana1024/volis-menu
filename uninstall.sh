#!/bin/bash
# omarchy:summary=Restore the official omarchy.menu and remove the volis.menu clone
# omarchy:group=plugin
set -euo pipefail

# Restores the stock first-party menu (bar slot, IPC routing, shell.json).
omarchy-plugin-enable omarchy.menu

rm -rf "$HOME/.config/omarchy/plugins/volis.menu"
rm -rf "$HOME/.cache/quickshell"
omarchy-restart-shell

echo "volis.menu removed — official omarchy.menu restored."
