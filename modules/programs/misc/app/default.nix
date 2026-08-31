{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot
    opencode
    teams-for-linux
    telegram-desktop
    chromium
    libreoffice
    qbittorrent
    ghostty
    zed-editor
    pgadmin4-desktopmode
    qgis
    signal-desktop
    skopeo
    spotatui
    t3code
    marimo
  ];
}
