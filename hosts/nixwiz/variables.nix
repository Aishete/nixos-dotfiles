{
  username = "archdev"; # auto-set with install.sh, live-install.sh, and rebuild scripts.

  # Desktop Environment
  desktop = "hyprland"; # hyprland, i3, gnome, plasma6

  # Rice / Shell Template — Layer 2 of the 2D matrix (color x rice)
  # nixwiz    = Waybar + SwayNC + awww wallpaper (current baseline)
  # antiquity = Quickshell + hyprpaper + mako (art-nouveau shell)
  rice = "antiquity"; # nixwiz, antiquity

  # Theme & Appearance
  monospaceFont = "Iosevka Nerd Font"; # JetBrainsMono Nerd Font, Maple Mono NF, 0xProto Nerd Font
  bar = "waybar"; # waybar, hyprpanel, noctalia
  waybarTheme = "tokyo"; # stylish, minimal, tokyo
  rofiColorTheme = "zeibytes"; # catppuccin, zeibytes (or any .rasi in rofi/colors/)
  gapsStyle = "normal"; # compact (1/4), normal (4/5), spacious (8/12)
  sddmTheme = "jake_the_dog"; # astronaut, black_hole, purple_leaves, jake_the_dog, hyprland_kath
  defaultWallpaper = "galaxy.webp"; # Change with SUPER + SHIFT + W (Hyprland)
  hyprlockWallpaper = "galaxy.webp";

  # Default Applications
  terminal = "kitty"; # kitty, alacritty
  editor = "helix"; # nixvim, vscode, helix, doom-emacs, nvchad, neovim (primary)
  browser = "firefox"; # zen-beta, firefox, floorp
  tuiFileManager = "yazi"; # yazi, lf
  shell = "zsh"; # zsh, bash
  appimageSupport = true; # Enable/Disable AppImage support
  games = false; # Enable/Disable gaming module

  # Hardware
  hostname = "nixwiz";
  videoDriver = "amdgpu"; # nvidia, amdgpu, intel
  bluetoothSupport = true; # Whether your motherboard supports bluetooth

  # Localization
  timezone = "Asia/Phnom_Penh";
  locale = "en_US.UTF-8";
  clock24h = false;
  kbdLayout = "us,kh";
  kbdVariant = ",";
  consoleKeymap = "us";
}
