{ pkgs, ... }:
{
  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-ld.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    killall # For Killing All Instances Of Programs
    lm_sensors # Used For Getting Hardware Temps
    gnome-disk-utility # Disk Partitioning and Mounting Utility
    rclone # Cloning Utility
    jq # Json Formatting Utility
    bibata-cursors
    whitesur-cursors
    banana-cursor
    sddm-astronaut # Sddm Theme (Overlayed)
    kdePackages.qtsvg # Sddm Dependency
    kdePackages.qtmultimedia # Sddm Dependency
    kdePackages.qtvirtualkeyboard # Sddm Dependency
    fzf # Fuzzy Finder
    fd # Better find
    git # Git
    zoxide # Fast directory jumping (z/cd replacement)
    gh # Github Authentication Client
    libjxl # Support for JXL Images
    microfetch # Great little fetch program
    nix-prefetch-scripts # Find Hashes/Revisions of Nix Packages
    ripgrep # Improved Grep
    tldr # Improved Man
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    # aider-chat # AI in terminal (Optional: Client only)
    cmatrix # Matrix Movie Effect In Terminal
    alsa-utils
    brightnessctl
    pamixer
    playerctl
    hyprpicker
    libxi
    libxrandr
    libxkbcommon
    nixd
    # cowsay # Great Fun Terminal Program
    # duf # Utility For Displaying Disk Usage Information
    # dysk # Disk space util nice formattting
    # ffmpeg # Incredible Video Player / Editing
    # gemini-cli # CLI AI client ONLY (optional)
    # glxinfo # needed for inxi diag util
    # inxi # CLI System Information Tool
    # libsForQt5.qt5.qtgraphicaleffects # Sddm Dependency (Old)
    # libnotify # For Notifications
    # lolcat # Add Colors To Terminal Text
    # lshw # Detailed Hardware Information
    # mpv # Incredible Video Player
    # ncdu # Disk Usage Analyzer With Ncurses Interface
    # nixfmt-rfc-style # Nix Formatter
    # nwg-displays # configure monitor configs via GUI
    # onefetch # provides zsaneyos build information
    # pavucontrol # For Editing Audio Levels & Devices
    # pciutils # Collection Of Tools for Inspecting PCI Devices
    # picard # Change Metadata For Your Audio Files
    # pkg-config # Wrapper Script For Allowing Packages To Get Info About Other Packages
    # rhythmbox # audio player
    # socat # Needed For Screenshots
    # usbutils # Good Tools for USB Devices
    # uwsm # Universal Wayland Session Manager (optional must be enabled)
    # v4l-utils # Good For OBS Virtual Camera
    # warp-terminal # Terminal with AI support build in
    # waypaper # Change wallpaper
    # wget # Useful Network retriever
    # ytmdl # Download Music From Youtube

    # devenv
    # devbox
    # shellify
  ];
}
