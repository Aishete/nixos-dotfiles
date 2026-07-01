{
  username = "scriptwiz"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Theme & Appearance
  bar = "waybar"; # waybar, hyprpanel, noctalia
  waybarTheme = "minimal"; # stylish, minimal
  rofiColorTheme = "catppuccin"; # catppuccin, zeibytes (or any .rasi in rofi/colors/)
  sddmTheme = "astronaut"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "galaxy.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "galaxy.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty
  editor = "nvchad"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim
  browser = "firefox"; # zen-beta, firefox, floorp
  tuiFileManager = "yazi"; # yazi, lf
  shell = "zsh"; # zsh, bash
  games = true; # Enable/Disable gaming module

  # Hardware
  hostname = "script";
  videoDriver = "intel"; # nvidia, amdgpu, intel
  bluetoothSupport = false; # Whether your motherboard supports bluetooth

  # Localization
  timezone = "Asia/Phnom_Penh";
  locale = "en_US.UTF-8";
  clock24h = false;
  kbdLayout = "us";
  kbdVariant = "";
  consoleKeymap = "us";
}
