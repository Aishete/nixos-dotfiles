{ config, pkgs, ...}:

{ home.username = "scriptwiz";
  home.homeDirectory = "/home/scriptwiz";
  programs.git.enable = true;
  home.stateVersion = "25.11";
  programs.bash = {
	enable = true;
	shellAliases = {
		btw = "echo i use nixos btw";
};
};
}
