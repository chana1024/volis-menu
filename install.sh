#!/bin/bash
# omarchy:summary=Install the volis.menu plugin (Omarchy menu clone)
# omarchy:group=plugin
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$here/plugin"
target="$HOME/.config/omarchy/plugins/volis.menu"

[[ -d $src && -f $src/manifest.json ]] || {
  echo "install.sh: plugin/ directory not found next to this script" >&2
  exit 1
}

mkdir -p "$HOME/.config/omarchy/plugins"
rm -rf "$target"
cp -a "$src" "$target"

# The manifest keeps omarchy.clonedFrom = omarchy.menu, so the registry
# routes every omarchy.menu IPC call (keybinds, bar button) to this clone
# and swaps the bar slot from the official menu.
omarchy-plugin-enable volis.menu

# Quickshell may serve a stale compiled cache after QML changes.
rm -rf "$HOME/.cache/quickshell"
omarchy-restart-shell

echo "volis.menu installed — Super+Space opens the menu; look for the Windows submenu next to Apps."
