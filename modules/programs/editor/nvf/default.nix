{
  inputs,
  host,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../../../../hosts/${host}/variables.nix) terminal;

  # This toggle activates all the "maximal" logic in the block below
  isMaximal = true;

  nvfConfig = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      {
        config.vim = {
          # --- Core Settings ---
          viAlias = true;
          vimAlias = true;
          globals.mapleader = " ";
          opts= {
                expandtab = true;
                clipboard = "unnamedplug";
          };
          treesitter.enable = true;
          telescope.enable = true;
          comments.comment-nvim.enable = true;

          # --- LSP & Languages (The "Power" setup) ---
          lsp = {
            enable = true;
            formatOnSave = true;
            trouble.enable = true;
            lightbulb.enable = true;
            lspkind.enable = false;
            otter-nvim.enable = isMaximal;
          };

            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            nix.enable = true;
            markdown.enable = true;
            python.enable = isMaximal;
            rust.enable = isMaximal;
            html.enable = isMaximal;
            go.enable = isMaximal;
            bash.enable = isMaximal;
            ts.enable = isMaximal;
          };

          # --- Modern Completion ---
          autocomplete = {
            # Maximal uses blink-cmp (Faster, Rust-based)
            nvim-cmp.enable = !isMaximal;
            blink-cmp.enable = isMaximal;
          };

          # --- UI & Sidebars ---
          filetree.neo-tree.enable = true;
          tabline.nvimBufferline.enable = true;
          statusline.lualine = {
            enable = true;
            theme = "catppuccin";
          };

          notify.nvim-notify.enable = true;
          ui = {
            noice.enable = true; # Floating cmdline
            colorizer.enable = true;
            borders.enable = true;
            breadcrumbs.enable = isMaximal;
          };

          # --- Terminal Splits ---
          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
            setupOpts = {
              direction = "horizontal";
              open_mapping = "[[<leader>t]]";
            };
          };
          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;
          };

          # --- Keybinds ---
          keymaps = [
            {
              key = "<leader>e";
              mode = "n";
              action = ":Neotree toggle<CR>";
              silent = true;
              desc = "Toggle Explorer";
            }
            {
              key = "<leader>t";
              mode = "n";
              action = ":ToggleTerm<CR>";
              silent = true;
              desc = "Toggle Terminal";
            }
          ];

          # --- Git ---
          git = {
            enable = true;
            gitsigns.enable = true;
            neogit.enable = isMaximal;
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
          };
        };
      };
    ];
  };

  # Metadata fix to stop the 'license/teams/platforms' errors
  nvfPkg = nvfConfig.neovim.overrideAttrs (old: {
    meta =
      (old.meta or {})
      // {
        license = pkgs.lib.licenses.mit;
        platforms = pkgs.lib.platforms.all;
        mainProgram = "nvim";
        maintainers = [];
        teams = [];
      };
  });
in {
  # Add the fixed package to system
  environment.systemPackages = with pkgs; [
    nvfPkg
    ripgrep
    fd
  ];

  home-manager.sharedModules = [
    ({...}: {
      home.packages = [nvfPkg];
      programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
      home.sessionVariables.EDITOR = lib.mkForce "nvim";
    })
  ];
}
