# volis.menu — Omarchy menu with a running-windows switcher

A clone of the official [Omarchy](https://omarchy.org) command menu
(`omarchy.menu`, the Super+Space launcher) that adds live window switching:

- **Windows submenu** next to Apps, listing every running Hyprland toplevel —
  title, `Running · WS n · <monitor>` detail, current workspace first.
- **Real application icons** on every window row, resolved by matching the
  window class/appId against desktop entries (`StartupWMClass` first), not by
  guessing icon names from the class.
- **Root-menu search hits**: typing in the root menu finds running windows
  alongside apps, marked with a `󰖯` glyph and always ranked above app rows —
  the thing that is already running is the most actionable result.
- **Focus dispatch** through the hyprlua-compatible form
  `hyprctl dispatch "hl.dsp.focus({ window = 'address:0x…' })"`, executed
  after the menu closes so focus is not stolen back by the layer shell.
- Live refresh while the menu is open (open/close/move/title events).

Keybinds, the bar button, and every other menu behavior are unchanged: the
manifest keeps `omarchy.clonedFrom: "omarchy.menu"`, so the plugin registry
routes all `omarchy.menu` IPC traffic to this clone.

## Requirements

- Omarchy ≥ 4.0.3 (tested against 4.0.3-1)
- Hyprland with hyprlua dispatch (the `hl.dsp.focus` form)

## Install

```bash
git clone https://github.com/chana1024/volis-menu.git
cd volis-menu
./install.sh
```

`install.sh` copies `plugin/` to `~/.config/omarchy/plugins/volis.menu/`,
enables it (`omarchy-plugin-enable volis.menu` swaps the bar slot from the
official menu and disables it), clears the Quickshell compile cache, and
restarts the shell.

## Uninstall

```bash
./uninstall.sh
```

Restores the stock `omarchy.menu` and deletes the clone. Nothing under
`/usr/share` is ever touched.

## Upgrades

Omarchy package updates only write `/usr/share`; this clone lives in your
home directory, so **it is never overwritten** — but it is also a snapshot of
the official menu at clone time and will not gain upstream features. If a
future Omarchy release changes the shell plugin protocol and the menu
misbehaves, re-clone the official menu and re-apply the modifications
documented in [PATCHES.md](PATCHES.md) (or against this repo's copy).

## Implementation notes

Two things worth knowing if you hack on this:

1. **Third-party clones get a scoped `PluginShellApi`, not the host shell.**
   In practice its `appLibrary` capability can be null, which leaves the Apps
   submenu empty. This clone therefore instantiates a local `AppLibrary`
   (same `DesktopEntries` source) as a fallback when the injected capability
   is missing.
2. **A Hyprland window class is not an icon name** (`wechat` →
   `wechat-universal`, `Feishu` → `bytedance-feishu`). Window rows resolve
   their icon by matching class/appId/initialClass against desktop entries —
   `StartupWMClass` (`entry.startupClass` in Quickshell) first, then desktop
   id and name — and use the matched entry's `Icon=` value.

## License

MIT — derived from [Omarchy](https://omarchy.org) (MIT), © DHH.
