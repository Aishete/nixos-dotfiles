{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot
    blender
    opencode
    teams-for-linux
    telegram-desktop
    gimp
    chromium
    libreoffice
    qbittorrent
    rapidraw
    ghostty
    zed-editor
    pgadmin4-desktopmode
    qgis
    signal-desktop
    skopeo
    spotatui
  ];
}
