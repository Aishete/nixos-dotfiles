
{ config, lib, pkgs, ... }:

{
  imports =
    [  
    ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos-btw";  
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Phnom_Penh";

    xdg.portal = {
    enable = true;
    wlr.enable= true;
  };

  services.greetd = {
		enable = true;
		settings = {
		default_session = {
		command = "${pkgs.tuigreet}/bin/tuigreet --time --remember";
				user = "greeter";
		};
     }; 
  };


  users.users.scriptwiz = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
	shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };


  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    foot
    neovim
    lazygit
    kitty
    lazydocker

    pipewire
    brightnessctl
	sway
    swaybg
    nemo
    nwg-look
    quickshell
    grim
    slurp
    swappy
    wl-clipboard
    mako
    dconf
    jq
    socat
	mesa
	mesa-demos
	lm_sensors
	sysstat
	github-cli

    #for intel gpu
    intel-gpu-tools

	qutebrowser
	zsh
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-completions

	htop
	btop
	fff
	fzf
	bat

	docker
	docker-compose
  ];
  
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  
  nix.settings.experimental-features = ["nix-command" "flakes"];

  #Enable programs
  programs.firefox.enable = true;
  
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  services.pipewire.enable = true;
  services.openssh.enable = true;

  virtualisation.docker.enable = true;
  
  system.stateVersion = "25.11"; 
}

