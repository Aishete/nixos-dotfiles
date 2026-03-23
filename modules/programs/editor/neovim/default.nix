{
  inputs,
  host,
  pkgs,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix) terminal;
in
{
  environment.systemPackages = with pkgs; [
    gcc 
    nodejs
    nil
    nixfmt-rfc-style # 'nixfmt-tree' is older; rfc-style is the new standard
    ripgrep
    sshfs            # Essential for remote-sshfs.nvim
  ];

  home-manager.sharedModules = [
    (_: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        # Optional: ensure these aliases point to your wrapped nvim
        viAlias = true;
        vimAlias = true;
	plugins = with pkgs.vimPlugins; [
		remote-sshfs-nvim
	];
      };

      # This symlinks your local folder to ~/.config/nvim
      xdg.configFile."nvim".source = inputs.ma-neovim;

      xdg.desktopEntries = {
        "nvim" = {
          name = "Neovim wrapper";
          genericName = "Text Editor";
          comment = "Edit text files";
          # Using the terminal variable to launch nvim in your preferred terminal
          exec = "${pkgs.${terminal}}/bin/${terminal} --class \"nvim-wrapper\" -e nvim %F";
          icon = "nvim";
          mimeType = [
            "text/plain"
            "text/x-makefile"
          ];
          categories = [
            "Development"
            "TextEditor"
          ];
          terminal = false; 
        };
      };
    })
  ];
}
