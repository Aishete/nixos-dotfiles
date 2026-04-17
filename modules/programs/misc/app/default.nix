{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    godotPackages_4_5.godot
    blender
    opencode
    crush
    penpot-desktop
    teams-for-linux
    telegram-desktop
    blanket
    gimp
  ];
}
