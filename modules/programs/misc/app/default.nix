{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godot
    teams-for-linux
    telegram-desktop
    chromium
    libreoffice
    qbittorrent
    # ghostty
    zed-editor
    # pgadmin 9.14 (unstable) fails to build with psycopg 3.3.5 (_py_codecs
    # tuple) — nixpkgs#569095, still open. Pin to stable-channel pgadmin 9.11
    # (psycopg 3.2.12) until upstream fixes it; revisit on next bump.
    pkgs.stable.pgadmin4-desktopmode
    qgis
    signal-desktop
    skopeo
    spotatui
    marimo
  ];
}
