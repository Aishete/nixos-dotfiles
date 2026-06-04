{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godotPackages_4_5.godot
    blender
    opencode
    teams-for-linux
    telegram-desktop
    blanket
    gimp
    chromium
    libreoffice
    qbittorrent
    rapidraw
    zed
  ];
}
