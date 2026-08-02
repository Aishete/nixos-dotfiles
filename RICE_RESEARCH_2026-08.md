# NixOS Hyprland Rice — Deep Research (gortex + config archaeology)
Date: 2026-08-02 · Repo: /home/archdev/NixOS · Branch: nixwiz

## 0. Method
- gortex graph (NixOS repo: 5579 nodes / 6901 edges; nix 4500, lua 10, bash 42,
  css 105, javascript 40, json 28, markdown 59) — `analyze` dead_code/cycles/
  hotspots/todos/stale_code → structurally CLEAN (3 NOTE todos, no dead code,
  no cycles, no hotspots). Graph value here is low (config repo); the real
  findings come from config archaeology below + quickshell's own QML loader
  (`quickshell --path shell.qml` → "Configuration Loaded" = authoritative).

## 1. How the rice handles things (architecture)

### 1.1 The 2D matrix (color × rice)
- Layer-1 color themes: modules/themes/{Catppuccin, Dracula, rose-pine, TokyoNight}
  — GTK/Qt/Kvantum/GTK-theme packages + host vars (accent, variant).
- Layer-2 rice shells: `rices/default` (Waybar+SwayNC+hyprpaper) vs
  `rices/antiquity` (Quickshell+hyprpaper+mako). Selected by host `variables.nix`:
  - nixwiz: `rice = "antiquity"; bar = "waybar"; waybarTheme = "tokyo"`
  - Default: `bar = "hyprpanel"` (rice unset → "default")
  - script: `bar = "waybar"`
- Dispatch: parent `modules/desktop/hyprland/default.nix` imports the rice
  module conditionally (`lib.optional (rice == "default") ...` etc).

### 1.2 Lua config runtime (Hyprland's lua front-end)
- `lua/hyprland.lua` = entry: requires monitors, variables, settings,
  animations, pcall(rices), binds, rules, plugins; on hyprland.start starts
  `quickshell.service hyprpaper.service` via systemctl --user (idempotent,
  works for manual TTY launches too); pcall(require "monitor_hotplug").
- `lua/variables.nix` → hypr/variables.lua: script store paths (autoclicker,
  batterynotify, clipmanager, appearance, gapstoggle, keyboardswitch,
  keybinds-yad, rofimusic, screen-record, screenshot, wallpaper, zoom,
  presentation-mirror, notes) + mainMod=SUPER, bar, term, editor, browser,
  fileManager, kbdLayout/Variant, gaps_in/out.
- `lua/binds.lua` (dispatcher): loads binds-common + per-rice
  (binds-default/binds-antiquity) via `require("rice").rice` (generated
  `hypr/rice.lua` returns `{ rice = "<host value>" }`). Soft separation.
- `lua/settings.lua`: env vars (wayland/ibus/qt/xcursor), hl.config (input,
  general, decoration, group, render, ecosystem, misc, xwayland, dwindle,
  master, binds), 3-finger gesture → workspace. hyprland.start also execs
  wallpaper+bar (default rice), swaync, nm-applet, cliphist watchers,
  batterynotify, polkit.
- `lua/monitors.lua`: eDP-1 (0x0), DP-1 (1920x0), HDMI-A-2 (3840x0) +
  workspace→monitor rules (1-3 DP-1, 4-6 HDMI-A-2, 7-9 eDP-1).
- `lua/plugins.lua`: hypr-dynamic-cursors (tilt mode) load + config.

### 1.3 Antiquity rice (Quickshell) — the shell
- `rices/antiquity/default.nix` (own sharedModule):
  - packages: quickshell, hyprpaper, qt6.qt5compat, antiquityRaise.
  - xdg.configFile: quickshell/ (vendored source), mako/config, kitty/antiquity,
    hypr/rices.lua (theme="antiquity" + antiquityRaiseBin + load marker),
    hypr/monitor_hotplug.lua (monitor.added → re-apply wallpaper),
    hypr/hyprpaper.conf (preloads ALL theme wallpapers by symlink path +
    wallpaper= for 3 monitors).
  - Wallpaper pool: ~/.local/share/wallpapers/{georges_riom_collage,
    carnation_collage, oc_the_blackboard, galaxy, ALCHEMY-dark, HIRAETH} +
    canonical selected.webp (force=true symlink).
  - systemd user services: quickshell (graphical-session.target, Restart
    on-failure 2s), hyprpaper (same + ExecStartPost applyWallpaper).
  - home.activation creates ~/.local/state/quickshell.
  - buuf-nestort icon theme from flake input (not vendored).
- Quickshell QML (`source/quickshell/`):
  - shell.qml: loads WidgetScreen, RadialTaskbar, Sidebar, Bar, SettingsWindow.
  - Config.qml (Singleton): stateDir (writable JSON: settings/favorites/
    widgets), wallpaper routing (applyWallpaper → canonical selected.webp →
    preloaded texture → no black gap), selectedWallpaper override file +
    inotify watch, OWM key from ~/.local/state/quickshell/.env (never in
    repo), 5 themes (helios/eris/priapus/eros/hades) with colors +
    defaultWallpaperPath, settings.json persistence (currentTheme,
    openWeatherMap.city=Phnom Penh, bar sizing, execCommands), theme switch
    resets wallpaper override, weather fetch timer (10 min).
  - Bars:
    * WidgetScreen.qml: full-screen stats panel (WlrLayer.Bottom), Repeater
      over Config.widgets[monitor] → Loader per widget (Weather/Clock +
      commented CPU/RAM/GPU), widgetScreen_<mon> IpcHandler toggleFront →
      Overlay.
    * RadialTaskbar.qml: main curved bar (bottom+left+right, height 150),
      workspace star buttons (roman numerals) along a quadratic curve,
      systray arc, radialBar_<mon> toggleFront → Overlay; hover edges change
      isOpen.
    * Sidebar.qml: closerPanel (transparent full-screen click-catcher, layer
      Top when popup open) + mainMenu_<mon> toggleMainMenu → SidebarPopup.
    * Bar.qml: bottom taskbar (visible: true now), Workspaces (roman numeral
      buttons), appLauncher button (center), SysTray + Power/Gpu/Ram widgets
      (right), appLauncher_<mon> toggleAppLauncher, workspacesBar_<mon>
      toggleFront; overlay click-catcher PanelWindow for SystemPopup.
    * Popups: MainMenu (Control Panel: network→nm-connection-editor, volume
      slider, settings, power), PowerMenu (tarot-card SVGs), ThemingMenu,
      FavoriteAppsMenu, AppLauncher (fuzzy app search), SettingsWindow.
- SUPER+Grave (`antiquity-raise` script): resolves focused monitor at
  keypress, then 4 quickshell IPC calls: mainMenu_ toggleMainMenu,
  workspacesBar_ toggleFront, radialBar_ toggleFront, widgetScreen_
  toggleFront → menu + bottom bar + left bar + stats panel all raised to
  Overlay. Bind in binds-antiquity.lua via absolute store path.

### 1.4 Default rice (Waybar/SwayNC/hyprpaper)
- `rices/default/default.nix`: hyprpaper package + conf (3 monitors, no
  preloads), applyWallpaper script (hardcoded monitors!), systemd user
  service hyprpaper with Install.WantedBy = "default.target" (NOT
  graphical-session.target — boot race), ExecStartPost apply.
- scripts/wallpaper.nix (shared, used by binds): applies wallpaper to
  hardcoded eDP-1/DP-1/HDMI-A-2, prefers selectedWallpaper override.

## 2. Key handling mechanisms (how it "handles things")
| Concern | Mechanism | Notes |
|---|---|---|
| Rice identity | hypr/rice.lua `{rice=...}` (host var) → binds dispatcher | soft-separate binds |
| Theme identity (antiquity) | hypr/rices.lua global `theme` | legacy dual (rice.lua vs rices.lua) |
| Wallpaper no-black-gap | preload ALL wallpapers by symlink path; every apply routes through canonical selected.webp | hyprpaper 0.8.4 has NO preload IPC verb |
| Wallpaper apply timing | systemd ExecStartPost (waits for socket 30s) + quickshell applyWallpaper on load + monitor_hotplug on add | flash-free, hotplug-safe |
| User wallpaper override | ~/.local/state/quickshell/selectedWallpaper file, inotify-watched | resets on theme switch |
| Bars raise | frontMode bool per PanelWindow + IPC toggleFront → WlrLayer Overlay | SUPER+Grave = 4 IPC calls |
| Popup close | transparent full-screen click-catchers (closerPanel / overlay) | |
| Secrets | OWM key in ~/.local/state/quickshell/.env (chmod 600), never repo | runtime secret |
| Persistence | settings.json/favoriteapps.json/widgets.json in state dir | FileView+JsonAdapter |
| Services | systemd user services bound to graphical-session.target; hyprland.start also starts them (manual launch) | |
| Monitor hotplug | hl.on("monitor.added") → re-run applyWallpaper | lua top-level only |

## 3. Findings (prioritized)

### P0 — current breakage (fixed this session)
- F1. quickshell crash-loop: WidgetScreen.qml brace corruption (duplicated
  PanelWindow) + RadialTaskbar.qml missing `import Quickshell.Io` (IpcHandler
  not a type). Fixed + verified via quickshell loader. (commits 16b2cd6,
  a3caafe; earlier IpcHandler-in-PanelWindow bug 2d16213/bdc8360)
- F2. SUPER+Grave raised wrong bars (top vs bottom) — Bar.qml anchor was
  top:true → bottom:true; visible:true so always shown. (ee79e58, cd15c59)

### P1 — real bugs (latent)
- F3. `lua/settings.lua:42` — `hl.exec_cmd("rm '$XDG_CACHE_HOME/cliphist/db'")`
  uses `rm` (user blocks destructive deletes) AND `$XDG_CACHE_HOME` is not
  interpolated by Lua (single quotes + literal $ → rm fails silently or
  removes nothing / wrong path). Use `cliphist wipe` or drop the line.
- F4. Default rice hyprpaper: Install.WantedBy = "default.target" (boot race
  with compositor, same bug antiquity's comments document); hardcoded monitor
  list (no dynamic hyprctl monitors); no preloads (black flash on theme/
  wallpaper switch); no monitor_hotplug for default rice. Asymmetric with
  antiquity. Should adopt antiquity's pattern (graphical-session.target +
  dynamic monitors + preloads + hotplug).
- F5. `scripts/wallpaper.nix` hardcodes monitors (eDP-1/DP-1/HDMI-A-2) —
  breaks on other hardware / hotplug; should enumerate via hyprctl.
- F6. Config.qml line 139: `themes[themes[settings.currentTheme] == null ? 'helios' : settings.currentTheme]` — if settings.currentTheme is invalid, `themes[null]`... actually the ternary guards it, but if settings file has a theme not in themes{}, `themes[settings.currentTheme]` is undefined → colors undefined → all widgets transparent/broken. Consider fallback binding on colors.

### P2 — cleanup / robustness
- F7. Workspaces.qml:33 binding loop (getColor writes focusedWindowId read by
  the binding) — infinite re-eval, minor CPU. Use a local var.
- F8. Workspaces.qml:17 / RadialTaskbar.qml:167: `w.monitor.name` TypeError
  when monitor is null (headless/validation, monitor disconnect race).
- F9. Workspaces.qml:22 `anchors.centerIn: parent.centerIn` — invalid
  (centerIn takes an Item, not an anchor); should be `parent` (or remove).
- F10. Duplicate identity files: rice.lua (returns table) vs rices.lua
  (sets globals theme + antiquityRaiseBin). Two sources of truth for the same
  axis; binds dispatcher uses rice.lua, binds-antiquity uses rices.lua
  globals. Consolidate into one (rice.lua returns {rice, antiquityRaiseBin}).
- F11. Bar.qml:25 `WlrLayershell.layer: root.frontMode ? Overlay : Bottom`
  + visible:true — when frontMode toggles, layer jumps Bottom↔Overlay; the
  bar is always "visible" but at Bottom it may be occluded by fullscreen;
  that's intended (raise-on-demand). OK.
- F12. Config.qml widgetTypes only Weather/Clock; CPU/RAM/GPU widgets exist
  in widgets/ but are commented out — either wire them (addWidget from
  SettingsWindow) or remove dead code.
- F13. Config.qml OWM: `settings.openWeatherMap.apiKey` placeholder string in
  repo ("***SE...***") — fine (placeholder), but `owmApiKey` falls back to it
  if .env missing → weather fetch with a fake key logs warnings. Consider
  disabling weather when key is the placeholder.

### P3 — polish / UX
- F14. WlrLayershell deprecated `width:` on PanelWindow (Bar.qml) → use
  implicitWidth.
- F15. SettingsWindow.qml anchors-on-layout items (317/358/423/488) —
  undefined behavior per Qt; use Layout.alignment.
- F16. SVG pattern resolution warnings (tarot_card_reboot/hibernate) — broken
  #pattern refs; cosmetic but fixable in the SVGs.
- F17. eval warnings (hyprland.settings empty, qt.platformTheme gtk
  deprecated, protonvpn-gui renamed) — silence/pin.

## 4. Suggested improvement batch (next)
1. Apply P1 fixes: F3 (cliphist wipe), F4+F5 (default rice parity:
   graphical-session.target, dynamic monitors, preloads, hotplug),
   F6 (theme fallback), F7-F9 (Workspaces robustness).
2. F10 consolidation: single rice identity module.
3. F12: enable CPU/RAM/GPU widgets (SettingsWindow already has the toggle UI?)
   or remove dead commented code.
4. F13: weather key guard.
5. F14-F16: Qt/QML hygiene.
6. Then rebuild + `sudo nixos-rebuild switch` + `systemctl --user restart
   quickshell` + verify layers show all bars.
