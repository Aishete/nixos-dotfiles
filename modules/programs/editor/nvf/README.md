# NVF Editor Configuration

NVF is a Neovim configuration framework built with Nix. This module adds NVF as an editor option to your NixOS system.

## Setup

1. **Add NVF to flake.nix**: Add the following input to your `flake.nix`:
   ```nix
   nvf = {
     url = "github:notashelf/nvf";
     inputs.nixpkgs.follows = "nixpkgs";
   };
   ```

2. **Enable NVF**: In your host's `variables.nix` file (e.g., `./hosts/Default/variables.nix`), set:
   ```nix
   editor = "nvf";
   ```

## Configuration

The base configuration in `default.nix` enables:
- Theme support
- Treesitter (syntax highlighting)
- LSP (Language Server Protocol)
- Telescope (fuzzy finder)
- nvim-cmp (autocompletion)
- which-key (keybinding help)
- comment.nvim (better commenting)
- gitsigns (git integration)
- nvim-tree (file explorer)

## Adding Plugins and Customization

You can customize your NVF configuration by modifying the `modules` array in `default.nix`. For example:

```nix
modules = [
  {
    config.vim = {
      theme.enable = true;
      theme.name = "catppuccin-mocha";
      
      treesitter.enable = true;
      
      lsp.enable = true;
      lsp.servers = ["nixd" "rust-analyzer" "gopls"];
      
      # Add more plugins here
      telescope.enable = true;
      cmp.enable = true;
    };
  }
];
```

## Adding Language Servers

To add language servers, include them in `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  nvfConfig.neovim
  nixd        # Nix language server
  nil         # Alternative Nix LSP
  nodejs      # For many LSPs
  ripgrep     # For telescope
  fd          # For telescope file finding
  # Add more language servers as needed
];
```

## Resources

- NVF Documentation: https://nvf.notashelf.dev/
- NVF GitHub: https://github.com/notashelf/nvf
- Example configurations on the NVF website