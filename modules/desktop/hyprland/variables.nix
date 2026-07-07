{
  host,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe getExe';
  inherit
    (import ../../../hosts/${host}/variables.nix)
    bar
    browser
    terminal
    tuiFileManager
    kbdLayout
    kbdVariant
    gapsStyle
    defaultWallpaper
    ;

  # Import script modules
  autoclicker = pkgs.callPackage ./scripts/autoclicker.nix {};
  batterynotify = pkgs.callPackage ./scripts/batterynotify.nix {};
  clipmanager = pkgs.callPackage ./scripts/clipmanager.nix {};
  gamemode = pkgs.callPackage ./scripts/gamemode.nix {};
  gapstoggle = pkgs.callPackage ./scripts/gaps-toggle.nix {};
  keyboardswitch = pkgs.callPackage ./scripts/keyboardswitch.nix {};
  keybinds-yad = pkgs.callPackage ./scripts/keybinds-yad.nix {};
  rofimusic = pkgs.callPackage ./scripts/rofimusic.nix {};
  screen-record = pkgs.callPackage ./scripts/screen-record.nix {};
  screenshot = pkgs.callPackage ./scripts/screenshot.nix {};
  wallpaper = pkgs.callPackage ./scripts/wallpaper.nix {inherit defaultWallpaper;};
  zoom = pkgs.callPackage ./scripts/zoom.nix {};
  presentation-mirror = pkgs.callPackage ./scripts/presentation-mirror.nix {};

  # Gap presets
  gaps = {
    compact = {gaps_in = 1; gaps_out = 4;};
    normal = {gaps_in = 4; gaps_out = 5;};
    spacious = {gaps_in = 8; gaps_out = 12;};
  };
  selectedGaps = gaps.${gapsStyle} or gaps.compact;
in {
  home-manager.sharedModules = [
    {
      xdg.configFile."hypr/variables.lua" = {
        text = ''
          -- Scripts
          autoclicker = "${getExe autoclicker}"
          batterynotify = "${getExe batterynotify}"
          clipmanager = "${getExe clipmanager}"
          gamemode = "${getExe gamemode}"
          gapstoggle = "${getExe gapstoggle}"
          keyboardswitch = "${getExe keyboardswitch}"
          keybinds_yad = "${getExe keybinds-yad}"
          rofimusic = "${getExe rofimusic}"
          screen_record = "${getExe screen-record}"
          screenshot = "${getExe screenshot}"
          wallpaper = "${getExe wallpaper}"
          zoom = "${getExe zoom}"
          presentation_mirror = "${getExe presentation-mirror}"

          -- Variables
          mainMod = "SUPER"
          bar = "${if bar == "waybar" then "waybar" else bar}"
          term = "${getExe pkgs.${terminal}}"
          editor = "code --disable-gpu"
          browser = "${browser}"
          fileManager = "${getExe pkgs.${terminal}} --class \"tuiFileManager\" -e ${tuiFileManager}"
          kbdLayout = "${kbdLayout}"
          kbdVariant = "${kbdVariant}"
          gaps_in = ${toString selectedGaps.gaps_in}
          gaps_out = ${toString selectedGaps.gaps_out}
        '';
      };
    }
  ];
}
