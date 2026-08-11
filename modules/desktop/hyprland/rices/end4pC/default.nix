{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  # Google Sans Flex variable font from the upstream-endorsed repo.
  googleSansFlex = pkgs.runCommand "google-sans-flex" { } ''
    mkdir -p $out/share/fonts/truetype
    cp ${inputs.end4pc-fonts}/GoogleSansFlex-VariableFont_*.ttf $out/share/fonts/truetype/
  '';
  # Space Grotesk (OFL) — not packaged in nixpkgs; vendored from google/fonts.
  spaceGrotesk = pkgs.runCommand "space-grotesk" { } ''
    mkdir -p $out/share/fonts/truetype
    cp ${pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/google/fonts/main/ofl/spacegrotesk/SpaceGrotesk%5Bwght%5D.ttf";
      name = "SpaceGrotesk.ttf";
      hash = "sha256-rK1t4fyTQ29cDx9BN3Ue8E8a6jBj5wNlNZcP/PvXn3I=";
    }} $out/share/fonts/truetype/
  '';
in {
  # end4pC rice — Layer-2 shell template (Quickshell Material-3 shell).
  # Vendored from pctrade/end4-pC (a fork of end-4's illogical-impulse), GPL-3.0.
  #
  # The shell is SELF-CONTAINED: it renders its own wallpaper (background panel,
  # no hyprpaper daemon), self-creates its config at
  # ~/.config/illogical-impulse/config.json (runtime state, NOT Nix-managed),
  # and ships its own icon set (material_symbols_rounded.json + SVGs). It does
  # NOT pair with waybar/swaync/mako — it brings its own bar, launcher,
  # notifications, lock screen, OSD and settings app.
  #
  # Runtime requirement: the shell imports Qt/KDE QML modules that nixpkgs'
  # quickshell doesn't carry on its import path — qtpositioning (weather),
  # qt5compat (GraphicalEffects), org.kde.syntaxhighlighting (AI chat code
  # blocks) and org.kde.kirigami (AppIcon — app icons in launcher/dock/taskbar).
  # We wrap quickshell with QML_IMPORT_PATH pointing at those (all prebuilt; no
  # source builds). Verified: the full 521-file shell loads on quickshell 0.3.0
  # with this env (loader: "Configuration Loaded").
  #
  # Fonts: the shell's own config asks for Google Sans Flex (main/title/numbers),
  # JetBrains Mono NF (mono + nerd-glyph icons), Readex Pro (reading) and Space
  # Grotesk (expressive). All four are installed (and alias-matched) rice-scoped
  # so the look the author intended is what renders.
  fonts.packages = with pkgs; [
    googleSansFlex
    nerd-fonts.jetbrains-mono
    readexpro
    spaceGrotesk
  ];
  # The shell's config asks for "JetBrains Mono NF" (with a space) but the nerd
  # font registers "JetBrainsMono NF" — normalize the pattern.
  fonts.fontconfig.localConf = ''
    <match target="pattern">
      <test name="family"><string>JetBrains Mono NF</string></test>
      <edit name="family" mode="prepend" binding="strong"><string>JetBrainsMono NF</string></edit>
    </match>
  '';
  fonts.fontconfig.enable = true;

  home-manager.sharedModules = [
    (
      { pkgs, lib, config, ... }:
      let
        # QML modules the fork's shell imports at load time (loader-verified).
        qmlModules = with pkgs; [
          qt6.qtpositioning # Weather.qml -> QtPositioning
          qt6.qt5compat # ReloadPopup/effects -> Qt5Compat.GraphicalEffects
          kdePackages.syntax-highlighting # AiChat code blocks -> org.kde.syntaxhighlighting
          kdePackages.kirigami.unwrapped # AppIcon -> org.kde.kirigami (app icons)
        ];
        importPath = lib.concatStringsSep ":" (map (p: "${p}/lib/qt-6/qml") qmlModules);

        # Wrapper: export the extra QML import path, then exec quickshell on the
        # vendored shell.qml (store path; Quickshell.shellPath resolves
        # assets/scripts/defaults/translations relative to it).
        quickshellEnd4pc = pkgs.writeShellScriptBin "quickshell-end4pc" ''
          export QML_IMPORT_PATH="${importPath}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
          exec ${pkgs.quickshell}/bin/quickshell --path "${./source}/shell.qml" "$@"
        '';

        # SUPER+SPACE handler: toggle the launcher (sidebarRight) on the focused
        # monitor. Same robust pattern as antiquity-raise (self-derived
        # HYPRLAND_INSTANCE_SIGNATURE + monitor resolved at keypress time).
        end4pcLauncher = pkgs.writeShellScriptBin "end4pc-launcher" ''
          HIS=$(ls -1 "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1)
          export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
          mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .name' | head -1)
          [ -z "$mon" ] && mon=eDP-1
          quickshell ipc call "sidebarRight_''${mon}" toggle || true
        '';

        # SUPER+escape handler: toggle the settings overlay (fork README).
        end4pcSettings = pkgs.writeShellScriptBin "end4pc-settings" ''
          HIS=$(ls -1 "''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/hypr" 2>/dev/null | head -1)
          export HYPRLAND_INSTANCE_SIGNATURE="$HIS"
          mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .name' | head -1)
          [ -z "$mon" ] && mon=eDP-1
          quickshell ipc call "settings_''${mon}" settingsToggle || true
        '';
      in
      {
        home.packages = with pkgs; [
          quickshell
          python3 # scripts/hyprland/autostart.py + colors scripts
          jq # switchwall.sh / hyprctl piping
          matugen # M3 dynamic color generation on wallpaper switch
          end4pcLauncher
          end4pcSettings
        ];

        # Rice identity + service list. The parent's rice.lua emission is gated
        # to the default rice, so THIS is the active definition on end4pC.
        # `services` is started by lua/hyprland.lua on hyprland.start (manual
        # TTY launches); no hyprpaper here — the shell renders its own wallpaper.
        xdg.configFile."hypr/rice.lua".text = ''
          -- DIAGNOSTIC (safe to keep): proves this file was actually required
          -- by Hyprland's lua at config load. If /tmp/rice_loaded.txt is absent
          -- or stale after a Hyprland (re)start, the file was never required
          -- (path bug) and the end4pC binds are skipped.
          os.execute("date +%s > /tmp/rice_loaded.txt")
          return {
            rice = "end4pC",
            services = "quickshell-end4pc.service",
            end4pcLauncherBin = "${end4pcLauncher}/bin/end4pc-launcher",
            end4pcSettingsBin = "${end4pcSettings}/bin/end4pc-settings",
          }
        '';

        # Runtime state dirs the shell expects (notes/todo/ai chats). config.json
        # itself is created by the shell on first run (~/.config/illogical-impulse).
        home.activation.createEnd4pcState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.local/state/user"
        '';

        systemd.user.services.quickshell-end4pc = {
          Unit = {
            Description = "end4pC Quickshell shell";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${quickshellEnd4pc}/bin/quickshell-end4pc";
            Restart = "on-failure";
            RestartSec = 2;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      }
    )
  ];
}
