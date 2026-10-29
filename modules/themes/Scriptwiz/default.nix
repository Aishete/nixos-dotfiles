{ host, pkgs, ... }:
let
  inherit (import ./palette.nix) colors font;
  catppuccin = "catppuccin-mocha-mauve";
in
{
  home-manager.sharedModules = [
    (_:
    {
      home.packages = with pkgs; [
        (pkgs.catppuccin-kvantum.override {
          variant = "mocha";
          accent = "green";
        })
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
            accents = [ "green" ];
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
        enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.apple-cursor;
        name = "macOS";
        size = 24;
      };
    })
  ];
}
