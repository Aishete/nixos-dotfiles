{ pkgs, bar, ... }:
# Toggle the bar, per-monitor aware.
#
# Waybar hosts (rice default, bar = "waybar") run ONE waybar instance per
# monitor, each with a runtime-generated config that pins `output` to that
# monitor (`waybar -c ~/.cache/waybar/config-<mon>.json`). Each monitor's bar
# is therefore an independent process that can be killed/started alone. This
# is what the CTRL+ESCAPE bind runs: it toggles the bar on the FOCUSED monitor
# only (other monitors untouched).
#
# Why runtime-generated configs instead of `waybar -m <mon>`: waybar 0.15
# has NO -m/--monitor flag ("Unrecognised token: -m"). Per-monitor bars are
# done via the config `output` key — one config per monitor. Generating them
# from the HM-managed config keeps the store symlink as the single source of
# truth and stays hotplug-safe (monitors are enumerated at toggle time).
#
# HyprPanel hosts (bar = "hyprpanel") run a single process that owns bars on
# every monitor — per-monitor control isn't possible there, so hyprpanel keeps
# the old global kill/start behavior (the bind degrades to global on those
# hosts).
#
# Modes:
#   toggle-bar                toggle the bar on the focused monitor
#   toggle-bar --monitor M    toggle the bar on monitor M
#   toggle-bar --global       toggle ALL bars (kill all if any run, else start all)
#   toggle-bar --start-all    ensure a bar runs on every connected monitor
#                             (session start; settings.lua `bar` exec)
#
# Why a script instead of a one-liner in the bind:
# - The running bar's comm is NOT "waybar": nixpkgs installs waybar behind a
#   makeCWrapper shim, so every waybar process has comm `.waybar-wrapped`
#   (15 chars — verified live). `pkill -x waybar` therefore NEVER matches;
#   only `-x .waybar-wrapped` does. BUT an -x pkill on .waybar-wrapped hits
#   ALL waybar processes — so per-monitor kills must be done by CMDLINE
#   pattern (config path or bare `waybar$`), never by comm. The old `pkill
#   "waybar|hyprpanel"` regex could also match lookalike processes.
# - A dedicated script keeps the dispatch command free of quotes/pipes, which
#   Hyprland's dispatcher handles unreliably (0.55 lua dispatch chokes on
#   embedded double quotes).
# - pgrep/pkill/jq/tr come from absolute store paths so the script works
#   regardless of Hyprland's exec PATH.
let
  procps = pkgs.procps;
  coreutils = pkgs.coreutils;
  barBin =
    if bar == "hyprpanel"
    then "hyprpanel" # HM program, on the user profile PATH
    else "${pkgs.waybar}/bin/waybar";
in
pkgs.writeShellScriptBin "toggle-bar" ''
  # --- resolve mode ---------------------------------------------------------
  MODE="focused"
  MON=""
  if [ $# -ge 1 ]; then
    case "$1" in
      --global)
        MODE="global"
        ;;
      --start-all)
        MODE="start-all"
        ;;
      --monitor)
        MODE="monitor"
        MON="$2"
        if [ -z "$MON" ]; then
          echo "toggle-bar: --monitor needs a monitor name" >&2
          exit 1
        fi
        ;;
      *)
        echo "toggle-bar: unknown argument: $1" >&2
        exit 1
        ;;
    esac
  fi

  # Focused monitor = the one the pointer/keyboard is on (mouse_move_focuses_monitor).
  if [ "$MODE" = "focused" ]; then
    MON=$(hyprctl monitors -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name')
    [ -n "$MON" ] || exit 1
    MODE="monitor"
  fi

  # --- hyprpanel: single process owns every bar, so always global -----------
  if [ "${bar}" = "hyprpanel" ]; then
    if ${procps}/bin/pgrep -x hyprpanel >/dev/null 2>&1; then
      ${procps}/bin/pkill -x hyprpanel 2>/dev/null || true
    else
      exec ${barBin}
    fi
    exit 0
  fi

  # --- waybar: one instance per monitor -------------------------------------
  # Per-monitor instances are identified by the generated config path:
  # .../config-<mon>.json in the -c argument. A legacy single-process bar
  # (started without -c, no output pinning) has a cmdline ending in "waybar".
  CFGDIR="$HOME/.cache/waybar"
  STYLE="$HOME/.config/waybar/style.css"
  safe_mon() {
    printf '%s' "$1" | ${coreutils}/bin/tr -c 'A-Za-z0-9._-' '_'
  }
  mon_cfg() {
    printf '%s/config-%s.json' "$CFGDIR" "$(safe_mon "$1")"
  }
  kill_legacy() {
    # Legacy single-process bar ONLY (cmdline ends in "waybar", no -c/-s args).
    # NEVER use `pkill -x .waybar-wrapped` here: nixpkgs installs waybar
    # behind a 15-char makeCWrapper shim, so EVERY waybar process has comm
    # `.waybar-wrapped` (verified live) — an -x pkill on it kills the
    # per-monitor instances we just spawned (SIGTERM ~120ms after spawn).
    ${procps}/bin/pkill -f 'waybar$' 2>/dev/null || true
  }
  mon_running() {
    [ -n "$1" ] && ${procps}/bin/pgrep -f "config-$(safe_mon "$1").json" >/dev/null 2>&1
  }
  any_running() {
    ${procps}/bin/pgrep -x waybar >/dev/null 2>&1 \
      || ${procps}/bin/pgrep -x .waybar-wrapped >/dev/null 2>&1
  }
  start_mon() {
    if ! mon_running "$1"; then
      # A legacy single-process bar covers every monitor — replace it before
      # spawning a per-monitor instance or the bar would double on this output.
      kill_legacy
      ${coreutils}/bin/mkdir -p "$CFGDIR"
      # Pin this monitor's output into a copy of the HM-managed config.
      # HM writes the config as an array of bar objects — handle both shapes.
      CFG=$(mon_cfg "$1")
      ${pkgs.jq}/bin/jq --arg out "$1" '
        if type == "array" then map(. + { output: [ $out ] })
        else . + { output: [ $out ] } end' \
        "$HOME/.config/waybar/config" > "$CFG.tmp" \
        && ${coreutils}/bin/mv -f "$CFG.tmp" "$CFG"
      ${barBin} -c "$CFG" -s "$STYLE" >/dev/null 2>&1 &
    fi
  }
  start_all() {
    kill_legacy
    # Wait for the monitor list (hyprland.start race) — up to 10s.
    MONS=""
    for i in $(${coreutils}/bin/seq 1 10); do
      MONS=$(hyprctl monitors -j 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[].name' 2>/dev/null)
      [ -n "$MONS" ] && break
      sleep 1
    done
    for m in $MONS; do
      start_mon "$m"
      # Hyprland 0.55 drops the layer configure event when several waybar
      # instances connect within milliseconds of each other — only the first
      # bar appears ("Timed out waiting for initial .configure", verified
      # live). Stagger the spawns so each output's bar actually shows.
      sleep 1.5
    done
  }

  case "$MODE" in
    monitor)
      if mon_running "$MON"; then
        ${procps}/bin/pkill -f "config-$(safe_mon "$MON").json" 2>/dev/null || true
      else
        start_mon "$MON"
      fi
      ;;
    global)
      if any_running; then
        ${procps}/bin/pkill -x waybar 2>/dev/null || true
        ${procps}/bin/pkill -x .waybar-wrapped 2>/dev/null || true
        kill_legacy
      else
        start_all
      fi
      ;;
    start-all)
      start_all
      ;;
  esac
''
