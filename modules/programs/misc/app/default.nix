{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    godotPackages_4_5.godot
    blender
    opencode
    crush
	teams
	telegram-desktop
  ];
}
