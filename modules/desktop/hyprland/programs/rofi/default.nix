{ pkgs, lib, host, ... }:
let
  inherit (import ../../../../../hosts/${host}/variables.nix) terminal rofiColorTheme;
  inherit (lib) getExe;

  # Dynamically patch colors.rasi files to use the chosen color scheme
  launchersWithTheme = pkgs.runCommand "rofi-launchers-${rofiColorTheme}" {} ''
    cp -r ${./launchers} $out
    chmod -R +w $out
    for f in $(find $out -name "colors.rasi"); do
      substituteInPlace "$f" \
        --replace-fail '~/.config/rofi/colors/catppuccin.rasi' \
        '~/.config/rofi/colors/${rofiColorTheme}.rasi'
    done
  '';
in
{
  home-manager.sharedModules = [
    (_: {
      programs.rofi = {
        enable = true;
        terminal = "${getExe pkgs.${terminal}}";
        plugins = with pkgs; [
          rofi-emoji
          rofi-games
        ];
        extraConfig = import ./config.nix;
      };
      xdg.configFile."rofi/launchers" = {
        source = launchersWithTheme;
        recursive = true;
      };
      xdg.configFile."rofi/colors" = {
        source = ./colors;
        recursive = true;
      };
    })
  ];
}
