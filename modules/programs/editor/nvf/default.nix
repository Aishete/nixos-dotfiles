{
  inputs,
  host,
  pkgs,
  ...
}:
let
  inherit (import ../../../../hosts/${host}/variables.nix) terminal;
  
  # Create nvf configuration
  
nvfConfig = inputs.nvf.lib.neovimConfiguration {
  inherit pkgs;
  modules = [
    {
      config.vim = {
        # ... (your existing theme, telescope, cmp, etc.)

        # 1. Broad LSP Server List
        lsp.servers = ["nixd" "rust-analyzer" "gopls" "pyright" "jinja_lsp" "html"];

        # 2. Enable Python specifically for Flask
        languages.python = {
          enable = true;
          lsp.enable = true;
          # Optional: Use black or ruff for formatting Flask projects
          formatters.black.enable = true;
        };

        # 3. Enable HTML/Web support for templates
        languages.html = {
          enable = true;
          lsp.enable = true;
        };

        # 4. Critical: Ensure Treesitter supports your template syntax
        treesitter.grammars = [
          "python"
          "html"
          "jinja2"
          "nix"
          "rust"
          "go"
        ];
      };
    }
  ];
};
in
{
  # Add nvf-wrapped neovim to system packages
  environment.systemPackages = with pkgs; [
    nvfConfig.neovim
    nixd
    nil
    nodejs
    ripgrep
    fd
  ];

  home-manager.sharedModules = [
    (_: {
      # Make nvf available in home-manager
      home.packages = [
        nvfConfig.neovim
      ];

      # Optional: Set as default editor
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        package = nvfConfig.neovim;
      };

      # Create a desktop entry for nvf (similar to your neovim config)
      xdg.desktopEntries = {
        "nvf" = {
          name = "NVF Neovim";
          genericName = "Text Editor";
          comment = "Edit text files with NVF configuration";
          # Using the terminal variable to launch nvim in your preferred terminal
          exec = "${pkgs.${terminal}}/bin/${terminal} --class \"nvf-wrapper\" -e nvim %F";
          icon = "nvim";
          mimeType = [
            "text/plain"
            "text/x-makefile"
            "text/x-nix"
          ];
          categories = [
            "Development"
            "TextEditor"
          ];
          terminal = false; # Important: set to false since we're calling kitty directly
        };
      };
    })
  ];
}
