{
  host,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) bar waybarTheme;
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
    ++ lib.optional (bar == "hyprpanel") ./programs/hyprpanel
    ++ lib.optionals (bar == "noctalia") [
      ./programs/swaync
      ./programs/noctalia
    ]
    ++ lib.optionals (bar == "waybar") [
      ./programs/swaync
      ./programs/waybar/${waybarTheme}.nix
    ];

  environment.systemPackages = with pkgs; [
    pavucontrol
    swappy
    cliphist
    wl-clipboard
    wl-mirror
    hyprlandPlugins.hypr-dynamic-cursors
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
      {config, ...}: {
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

        systemd.user.services.awww-daemon = {
          Unit.Description = "AWW daemon for wallpaper management";
          Unit.PartOf = [ "graphical-session-pre.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.awww}/bin/awww-daemon";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # Set wallpaper
        services.awww.enable = true;

        # Hyprland lua config files
        xdg.configFile = {
          "hypr/hyprland.lua".source = ./lua/hyprland.lua;
          "hypr/monitors.lua".source = ./lua/monitors.lua;
          "hypr/settings.lua".source = ./lua/settings.lua;
          "hypr/animations.lua".source = ./lua/animations.lua;
          "hypr/binds.lua".source = ./lua/binds.lua;
          "hypr/rules.lua".source = ./lua/rules.lua;
          "hypr/plugins.lua".text = ''
            -- Dynamic cursors plugin
            if hl.plugin.load then
              hl.plugin.load("${pkgs.hyprlandPlugins.hypr-dynamic-cursors}/lib/libhypr-dynamic-cursors.so")
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
