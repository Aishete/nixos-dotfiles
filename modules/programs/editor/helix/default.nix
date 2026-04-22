{
  pkgs,
  inputs,
  ...
}: {
  home-manager.sharedModules = [
    (_: {
      programs.helix = {
        enable = true;

        extraPackages = with pkgs; [
          # LSPs
          nixd
          alejandra
          nodePackages.vscode-langservers-extracted
          nodePackages.typescript-language-server
          tailwindcss-language-server
          nodePackages.prettier
          pyright
          black
          rust-analyzer
          marksman
        ];

        # 1. We define the transparent theme here
        themes = {
          catppuccin_mocha_transparent = {
            inherits = "catppuccin_mocha";
            "ui.background" = {};
          };
        };

        settings = {
          # 2. We use the transparent theme name here (ONLY ONCE)
          theme = "catppuccin_mocha_transparent";

          editor = {
            line-number = "relative";
            cursorline = true;
            color-modes = true;
            true-color = true;
            bufferline = "always";
            indent-guides.render = true;

            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };

            whitespace.render = {
              tab = "all";
              newline = "none";
            };

            gutters = ["diff" "line-numbers" "spacer" "diagnostics"];

            statusline = {
              left = ["mode" "spinner" "read-only-indicator" "diagnostics"];
              center = ["file-name" "file-modification-indicator"];
              right = [
                "version-control"
                "selections"
                "position"
                "total-line-numbers"
                "file-encoding"
                "file-type"
              ];
              separator = "│";
            };

            auto-completion = true;
            auto-format = true;
            smart-tab.enable = false;
            file-picker.hidden = true;

            lsp = {
              display-inlay-hints = true;
              display-progress-messages = true;
            };

            soft-wrap = {
              enable = true;
              wrap-at-text-width = false;
            };
          };

          keys.normal = {
            "esc" = ["collapse_selection" "keep_primary_selection"];
          };
        };

        languages = {
          language-server = {
            nixd = {
              command = "nixd";
              config.nixd = {
                nixpkgs.expr = "import ${inputs.nixpkgs} { }";
                formatting.command = ["alejandra"];
              };
            };
            tailwindcss-ls = {
              command = "tailwindcss-language-server";
              args = ["--stdio"];
            };
          };

          language = [
            {
              name = "nix";
              language-servers = ["nixd"];
              formatter = {command = "alejandra";};
              auto-format = true;
            }
            {
              name = "html";
              language-servers = ["vscode-html-language-server" "tailwindcss-ls"];
              formatter = {
                command = "prettier";
                args = ["--parser" "html"];
              };
              auto-format = true;
            }
            {
              name = "css";
              language-servers = ["vscode-css-language-server" "tailwindcss-ls"];
              formatter = {
                command = "prettier";
                args = ["--parser" "css"];
              };
              auto-format = true;
            }
            {
              name = "javascript";
              language-servers = ["typescript-language-server" "tailwindcss-ls"];
              formatter = {
                command = "prettier";
                args = ["--parser" "typescript"];
              };
              auto-format = true;
            }
            {
              name = "typescript";
              language-servers = ["typescript-language-server" "tailwindcss-ls"];
              formatter = {
                command = "prettier";
                args = ["--parser" "typescript"];
              };
              auto-format = true;
            }
          ];
        };
      };
    })
  ];
}
