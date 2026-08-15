{ host, pkgs, ... }:
let
  inherit (import ./palette.nix) colors font;
  catppuccin = "catppuccin-mocha-mauve";
in
{
  home-manager.sharedModules = [
    (_:
    let
      # Use Catppuccin Mocha as base GTK theme (close enough to Tokyo Night)
      # The purple accent (#C4A7E7) is very close to Mauve (#CBA6F7)
    in {
      home.packages = with pkgs; [
        pkgs.catppuccin-kvantum.override {
          variant = "mocha";
          accent = "mauve";
        }
      ];

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
        style.name = "kvantum";
      };
      gtk = {
        enable = true;
        gtk2.force = true;
        theme = {
          name = "${catppuccin}-compact";
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            accents = [ "mauve" ];
            size = "compact";
          };
        };
        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };
        gtk3.extraConfig = {
          "gtk-application-prefer-dark-theme" = "1";
        };
        gtk4.extraConfig = {
          "gtk-application-prefer-dark-theme" = "1";
        };
      };

      home.sessionVariables = {
        ADW_COLOR_SCHEME = "prefer-dark";
      };

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.apple-cursor;
        name = "macOS";
        size = 24;
      };
    })
  ];
}
