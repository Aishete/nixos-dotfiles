{
  host,
  inputs,
  lib,
  pkgs,
  ...
}: let
  hostVars = import ../../../hosts/${host}/variables.nix;
  inherit (hostVars) bar waybarTheme;
  # Layer-2 rice selector; defaults to "default" for hosts that don't define it
  rice = hostVars.rice or "default";
in let
  # hypr-dynamic-cursors: nixpkgs pins rev f5ba36c (2026-07-21), which crashes
  # on Hyprland 0.56.2 ("plugin crashed/threw in main"). The v0.56.2 compat fix
  # landed upstream 2026-08-06 (rev 5a22428, pinned for Hyprland efb5099).
  # Override until nixpkgs bumps past it.
  dynamic-cursors = pkgs.hyprlandPlugins.hypr-dynamic-cursors.overrideAttrs (old: {
    version = "0-unstable-2026-08-06";
    src = pkgs.fetchFromGitHub {
      owner = "VirtCode";
      repo = "hypr-dynamic-cursors";
      rev = "5a224284872208b5324759d535d65061043725de";
      hash = "sha256-BQjuQplkQFA30/7evDxmEAvr2ArIG09JffEBQhuzo80=";
    };
  });
in {
  imports =
    [
      ../../themes/Catppuccin
      ./variables.nix
      ./programs/wlogout
      ./programs/rofi
      ./programs/hypridle
      ./programs/hyprlock
    ]
    # Layer-2 rice module (shell template). Only the `default` rice (Waybar+
    # SwayNC+hyprpaper) is currently used; the rice matrix is kept so hosts can
    # select bar variants (waybar/hyprpanel/noctalia) via `bar`. Common config
    # (lua binds, xdg portals, hyprland wm) stays in this parent module.
    ++ lib.optional (rice == "default") ./rices/default
    ++ lib.optionals (rice == "default" && bar == "hyprpanel") ./programs/hyprpanel
    ++ lib.optionals (rice == "default" && bar == "noctalia") [
      ./programs/swaync
      ./programs/noctalia
    ]
    ++ lib.optionals (rice == "default" && bar == "waybar") [
      ./programs/swaync
      ./programs/waybar/${waybarTheme}.nix
    ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    swappy
    cliphist
    wl-clipboard
    wl-mirror
    dynamic-cursors
  ];

  systemd.user.services.hyprpolkitagent = {
    description = "Hyprpolkitagent - Polkit authentication agent";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.displayManager.defaultSession = "hyprland";

  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland;
  };

  home-manager.sharedModules = [
    (
      {config, lib, ...}: let
        # Brushbuddy animated cursor theme, built from the .ani pack in
        # ./cursors/brushbuddy (extract.py + build-theme.sh run at derivation time).
        # Overrides the theme module's pointerCursor (Catppuccin/TokyoNight set macOS).
        brushbuddy-cursor = pkgs.callPackage ./cursors/brushbuddy {};
      in {
        home.pointerCursor = lib.mkForce {
          gtk.enable = true;
          x11.enable = true;
          name = "Brushbuddy";
          package = brushbuddy-cursor;
          size = 40;
        };

        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
          ];
          xdgOpenUsePortal = true;
          configPackages = [pkgs.hyprland];
          config.hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
            "org.freedesktop.impl.portal.OpenURI" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.Print" = "gtk";
          };
        };

        xdg.configFile."hypr/icons" = {
          source = ./icons;
          recursive = true;
        };

        # Wallpaper is owned by the active rice module (both use hyprpaper).

        # Hyprland lua config files
        xdg.configFile = {
          "hypr/hyprland.lua".source = ./lua/hyprland.lua;
          "hypr/monitors.lua".source = ./lua/monitors.lua;
          "hypr/settings.lua".source = ./lua/settings.lua;
          "hypr/animations.lua".source = ./lua/animations.lua;
          "hypr/binds.lua".source = ./lua/binds.lua;
          "hypr/binds-common.lua".source = ./lua/binds-common.lua;
          "hypr/binds-default.lua".source = ./lua/binds-default.lua;
          # Generated per-host: tells binds.lua which rice is active so the same
          # chord can trigger a rice-specific action. Returns { rice = "default" }.
          "hypr/rice.lua".text = lib.mkIf (rice == "default") ''
            -- Default rice services. hyprpaper is WantedBy
            -- graphical-session.target, but on a MANUAL Hyprland launch that
            -- target never activates (and refuses manual start); the
            -- hyprland.start hook in lua/hyprland.lua starts this list
            -- directly. Idempotent under a display manager.
            return { rice = "default", services = "hyprpaper.service" }
          '';
          "hypr/rules.lua".source = ./lua/rules.lua;
          "hypr/plugins.lua".text = ''
            -- Dynamic cursors plugin
            if hl.plugin.load then
              hl.plugin.load("${dynamic-cursors}/lib/libhypr-dynamic-cursors.so")
            end

            if hl.plugin.dynamic_cursors then
              hl.config { plugin = { dynamic_cursors = {
                enabled = true,
                mode = "tilt",
                threshold = 2,
                tilt = {
                  limit = 5000,
                  activation = "negative_quadratic",
                  window = 100,
                  full = 60,
                },
                shake = {
                  enabled = true,
                  threshold = 4.0,
                  base = 4.0,
                  speed = 4.0,
                  influence = 0.0,
                  limit = 0.0,
                  timeout = 2000,
                  effects = false,
                  ipc = false,
                },
                hyprcursor = {
                  nearest = 1,
                  enabled = true,
                  resolution = 1,
                  fallback = "clientside",
                },
              }}}
            end
          '';
        };

        # Enable hyprland via home-manager but don't use settings
        wayland.windowManager.hyprland = {
          enable = true;
          package = pkgs.hyprland;
          systemd = {
            enable = true;
            variables = ["--all"];
          };
        };
      }
    )
  ];
}
