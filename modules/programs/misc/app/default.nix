{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot
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
