{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) monospaceFont;
in
{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      # Nerd Fonts
      maple-mono.NF
      pkgs.nerd-fonts.jetbrains-mono

      # Normal Fonts
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [
          monospaceFont
          "Maple Mono NF"
          "Noto Mono"
          "DejaVu Sans Mono" # Default
        ];
        sansSerif = [
          "Noto Sans"
          "DejaVu Sans" # Default
        ];
        serif = [
          "Noto Serif"
          "DejaVu Serif" # Default
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Also configure home-manager fontconfig so apps pick up the defaults
  home-manager.sharedModules = [
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            monospaceFont
            "Maple Mono NF"
            "Noto Mono"
            "DejaVu Sans Mono"
          ];
          sansSerif = [
            "Noto Sans"
            "DejaVu Sans"
          ];
          serif = [
            "Noto Serif"
            "DejaVu Serif"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    }
  ];
}
