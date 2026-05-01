{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    godotPackages_4_5.godot
    blender
    opencode
    crush
    teams-for-linux
    telegram-desktop
    blanket
    gimp
    neovim
    chromium
    libreoffice
  ];
}
