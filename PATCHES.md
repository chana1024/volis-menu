# Modifications vs the official omarchy.menu (4.0.3)

Everything lives in `plugin/Menu.qml`; `MenuModel.js`, `BarWidget.qml`, and
`manifest.json` are byte-identical to the official plugin (only the manifest
id/name fields differ, set by `omarchy-plugin-clone`). To re-apply after an
Omarchy upgrade: `omarchy-plugin-clone omarchy.menu`, then port the changes
below into the fresh clone, then `rm -rf ~/.cache/quickshell && omarchy-restart-shell`.

## 1. Imports

```qml
import Quickshell.Hyprland   // toplevels + raw events
import qs.services           // AppLibrary for the local fallback
```

## 2. Local AppLibrary fallback

Third-party clones receive a scoped `PluginShellApi` whose `appLibrary`
capability is null in practice (first-party plugins get the host shell
itself, which always has it). Without a fallback the Apps submenu renders
empty and every window icon is blank. Replace:

```qml
readonly property var appLibrary: root.shell ? root.shell.appLibrary : null
```

with:

```qml
AppLibrary { id: localAppLibrary }
readonly property var appLibrary: root.shell && root.shell.appLibrary
  ? root.shell.appLibrary : localAppLibrary
```

## 3. QML-native "windows" provider

- Add to the `providers` map:

  ```qml
  "windows": { native: true, volatile: true }
  ```

- In `startProviderForMenu()` and `loadProviderForMenu()`, treat
  `provider === "windows"` like `provider === "apps"` — mark loaded and call
  `mergeWindowRows()` instead of spawning the bash provider process.
- `property var toplevels: Hyprland.toplevels.values` plus a
  `Connections { target: Hyprland; onRawEvent }` that re-merges on
  openwindow/closewindow/movewindow/windowtitle/activewindow/workspace/
  changefloatingmode while the menu is open.
- `mergeWindowRows()` walks the toplevels (skipping
  `lastIpcObject.mapped === false`), builds one `kind: "window"` row each
  (`id: "windows." + address` — prefix `0x` if missing; label = title;
  description = `Running · WS n · monitor`; aliases = [class];
  action = `hyprctl dispatch "hl.dsp.focus({ window = 'address:0x…' })"`),
  sorts current-workspace-first, and merges via
  `MenuModel.swapProviderRows`.
- In `open()`, call `appLibrary.refreshIcons()` so late icon-index scans
  heal on open.

## 4. Window icon resolution

Window class ≠ icon name. `windowIconName(cls, initialClass, appId)`
normalizes those keys (lowercase, strip `.desktop`) and scans
`appLibrary.sortedEntries("")` for a desktop entry whose `startupClass`
(score 300), desktop id (200), or name (100) matches; returns the entry's
`icon` string, falling back to the raw class.

## 5. Windows submenu in the defaults

`rebuildItemsFromSources()` splices a normalized `windows` item (icon `󰖯`,
aliases windows/switch window/running, `provider: "windows"`) right after
the `apps` entry in the default rows, before the JSONC merge — so the user
extension file stays revertible.

## 6. Delegate

- `isApp: row.kind === "app" || row.kind === "window"` (drives image-icon
  rendering and hasIcon).
- Detail line visible for `kind === "window"` even without filter text.
- Trail column shows `󰖯` for window rows (marker distinguishing windows
  from app-launch rows in mixed search results).

## 7. Search ranking

`rebuildDisplay()` lifts every matching window row above all other rows
(apps included) after the current/drilldown concat, clearing their `section`
so the drilldown divider does not render twice around the hoisted block.

## Gotchas

- Hyprland running hyprlua parses dispatch IPC as Lua; the only working
  focus form is `hl.dsp.focus({ window = "address:0x…" })` (see
  `omarchy-hyprland-focus-app`).
- Quickshell may serve stale compiled QML after edits:
  `rm -rf ~/.cache/quickshell && omarchy-restart-shell`.
- Menu cursor convention: the first arrow key only activates the cursor on
  the edge row; injected E2E keypresses must press twice to move.
