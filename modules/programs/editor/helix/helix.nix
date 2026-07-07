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
          # ── Nix ────────────────────────────────────────────────────────────
          nixd
          alejandra

          # ── Web (HTML / CSS / JS / TS / Tailwind / Svelte) ────────────────
          vscode-langservers-extracted # html, css, json, eslint
          typescript-language-server
          tailwindcss-language-server
          svelte-language-server
          prettier
          astro-language-server # Astro support

          # ── Rust ───────────────────────────────────────────────────────────
          rust-analyzer
          rustfmt
          clippy
          cargo
          rustc
          lldb  # provides lldb-dap for the Helix debugger (DAP)

          # ── Go ─────────────────────────────────────────────────────────────
          gopls
          gofumpt          # stricter gofmt
          golangci-lint

          # ── Gleam ──────────────────────────────────────────────────────────
          gleam            # ships its own LSP: `gleam lsp`

          # ── Python ─────────────────────────────────────────────────────────
          pyright
          black
          ruff             # fast linter + formatter

          # ── Markdown / docs ────────────────────────────────────────────────
          marksman

          # ── TOML ───────────────────────────────────────────────────────────
          taplo

          # ── YAML ───────────────────────────────────────────────────────────
          yaml-language-server

          # ── Shell ──────────────────────────────────────────────────────────
          bash-language-server
          shellcheck
          shfmt

          # ── Git (CLI helpers that pair well with Helix) ────────────────────
          git
          delta            # better diffs
          gitui            # TUI git client you can pop into a terminal split
          lazygit          # alternative popular TUI
        ];

        # ── Transparent Catppuccin Mocha theme ──────────────────────────────
        themes = {
          catppuccin_mocha_transparent = {
            inherits = "catppuccin_mocha";
            "ui.background" = {};
          };
        };

        settings = {
          theme = "catppuccin_mocha_transparent";

          editor = {
            line-number = "relative";
            cursorline = true;
            color-modes = true;
            true-color = true;
            bufferline = "always";
            indent-guides.render = true;
            rulers = [80 120];           # visual column guides
            auto-save = true;
            completion-timeout = 50;     # snappier autocomplete popup
            idle-timeout = 100;

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
              left = [
                "mode"
                "spinner"
                "read-only-indicator"
                "diagnostics"
              ];
              center = [
                "file-name"
                "file-modification-indicator"
              ];
              right = [
                "version-control"   # current branch
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

            file-picker = {
              hidden = false;           # show dotfiles (.env, .gitignore, etc.)
              git-ignore = true;        # still respect .gitignore
              git-global = true;
              git-exclude = true;
            };

            lsp = {
              display-inlay-hints = true;
              display-progress-messages = true;
              snippets = true;
            };

            soft-wrap = {
              enable = true;
              wrap-at-text-width = false;
            };

            search = {
              smart-case = true;
              wrap-around = true;
            };
          };

          # ── Key bindings ───────────────────────────────────────────────────
          keys.normal = {
            # Better escape — collapse + keep primary only
            "esc" = ["collapse_selection" "keep_primary_selection"];

            # Quick buffer navigation
            "C-h" = "goto_previous_buffer";
            "C-l" = "goto_next_buffer";

            # Open file picker in project root with space+f
            "space" = {
              "f" = "file_picker";
              "F" = "file_picker_in_current_directory";
              "b" = "buffer_picker";
              "s" = "symbol_picker";          # workspace symbols
              "S" = "workspace_symbol_picker";
              "d" = "diagnostics_picker";
              "D" = "workspace_diagnostics_picker";
              "g" = "goto_definition";
              "r" = "rename_symbol";
              "a" = "code_action";
              "y" = "yank_to_clipboard";
              "p" = "paste_clipboard_after";
              "P" = "paste_clipboard_before";
            };
          };

          keys.insert = {
            # Exit insert with jk (fast escape alternative)
            "j" = {
              "k" = "normal_mode";
            };
          };
        };

        # ── Language servers & formatters ─────────────────────────────────
        languages = {
          language-server = {
            # Nix
            nixd = {
              command = "nixd";
              config.nixd = {
                nixpkgs.expr = "import ${inputs.nixpkgs} { }";
                formatting.command = ["alejandra"];
              };
            };

            # Tailwind — shared across HTML/CSS/JS/TS/Svelte/Astro
            tailwindcss-ls = {
              command = "tailwindcss-language-server";
              args = ["--stdio"];
            };

            # Svelte
            svelte-ls = {
              command = "svelteserver";
              args = ["--stdio"];
            };

            # Astro
            astro-ls = {
              command = "astro-ls";
              args = ["--stdio"];
              config = {
                typescript.tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
              };
            };

            # Go
            gopls = {
              command = "gopls";
              config = {
                "ui.inlayhint.hints" = {
                  assignVariableTypes = true;
                  compositeLiteralFields = true;
                  constantValues = true;
                  functionTypeParameters = true;
                  parameterNames = true;
                  rangeVariableTypes = true;
                };
              };
            };

            # Rust
            rust-analyzer = {
              command = "rust-analyzer";
              config.rust-analyzer = {
                cargo = {
                  allFeatures = true;
                  loadOutDirsFromCheck = true;
                  runBuildScripts = true;
                };
                checkOnSave = {
                  enable = true;
                  command = "clippy";   # use clippy instead of check
                  extraArgs = ["--" "-W" "clippy::pedantic"];
                };
                procMacro = {
                  enable = true;
                  ignored = {
                    "async-trait" = ["async_trait"];
                    "napi-derive" = ["napi"];
                    "async-recursion" = ["async_recursion"];
                  };
                };
                inlayHints = {
                  bindingModeHints.enable = true;
                  closureCaptureHints.enable = true;
                  closureReturnTypeHints.enable = "always";
                  discriminantHints.enable = "always";
                  expressionAdjustmentHints.enable = "always";
                  implicitDrops.enable = true;
                  lifetimeElisionHints = {
                    enable = "always";
                    useParameterNames = true;
                  };
                  parameterHints.enable = true;
                  rangeExclusiveHints.enable = true;
                  renderColons = true;
                  typeHints = {
                    enable = true;
                    hideClosureInitialization = false;
                    hideNamedConstructor = false;
                  };
                };
                completion = {
                  autoimport.enable = true;
                  autoself.enable = true;
                  callable.snippets = "fill_arguments";
                  postfix.enable = true;
                };
                diagnostics = {
                  enable = true;
                  experimental.enable = true;
                };
              };
            };

            # Gleam
            gleam-lsp = {
              command = "gleam";
              args = ["lsp"];
            };

            # Taplo (TOML)
            taplo-ls = {
              command = "taplo";
              args = ["lsp" "stdio"];
            };

            # YAML
            yaml-ls = {
              command = "yaml-language-server";
              args = ["--stdio"];
              config.yaml.schemas = {
                # Docker compose
                "https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json" = "docker-compose*.yml";
                # GitHub Actions
                "https://json.schemastore.org/github-workflow.json" = ".github/workflows/*.yml";
              };
            };

            # Ruff (Python fast linter acting as LSP)
            ruff-lsp = {
              command = "ruff";
              args = ["server" "--preview"];
            };

            # Bash
            bash-ls = {
              command = "bash-language-server";
              args = ["start"];
            };
          };

          # ── Per-language config ──────────────────────────────────────────
          language = [
            # Nix
            {
              name = "nix";
              language-servers = ["nixd"];
              formatter.command = "alejandra";
              auto-format = true;
            }

            # HTML
            {
              name = "html";
              language-servers = [
                "vscode-html-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "html"];
              };
              auto-format = true;
            }

            # CSS
            {
              name = "css";
              language-servers = [
                "vscode-css-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "css"];
              };
              auto-format = true;
            }

            # JavaScript
            {
              name = "javascript";
              language-servers = [
                "typescript-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "babel"];
              };
              auto-format = true;
            }

            # TypeScript
            {
              name = "typescript";
              language-servers = [
                "typescript-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "typescript"];
              };
              auto-format = true;
            }

            # JSX
            {
              name = "jsx";
              language-servers = [
                "typescript-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "babel"];
              };
              auto-format = true;
            }

            # TSX
            {
              name = "tsx";
              language-servers = [
                "typescript-language-server"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "babel-ts"];
              };
              auto-format = true;
            }

            # Svelte
            {
              name = "svelte";
              language-servers = [
                "svelte-ls"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "svelte" "--plugin" "prettier-plugin-svelte"];
              };
              auto-format = true;
            }

            # Astro
            {
              name = "astro";
              language-servers = [
                "astro-ls"
                "tailwindcss-ls"
              ];
              formatter = {
                command = "prettier";
                args = ["--parser" "astro" "--plugin" "@prettier/plugin-astro"];
              };
              auto-format = true;
            }

            # Rust
            {
              name = "rust";
              language-servers = ["rust-analyzer"];
              formatter.command = "rustfmt";
              auto-format = true;
            }

            # Go
            {
              name = "go";
              language-servers = ["gopls"];
              formatter.command = "gofumpt";
              auto-format = true;
            }

            # Gleam
            {
              name = "gleam";
              language-servers = ["gleam-lsp"];
              formatter = {
                command = "gleam";
                args = ["format" "--stdin"];
              };
              auto-format = true;
            }

            # Python
            {
              name = "python";
              language-servers = ["pyright" "ruff-lsp"];
              formatter.command = "black";
              auto-format = true;
            }

            # TOML
            {
              name = "toml";
              language-servers = ["taplo-ls"];
              formatter = {
                command = "taplo";
                args = ["fmt" "-"];
              };
              auto-format = true;
            }

            # YAML
            {
              name = "yaml";
              language-servers = ["yaml-ls"];
              formatter = {
                command = "prettier";
                args = ["--parser" "yaml"];
              };
              auto-format = true;
            }

            # JSON
            {
              name = "json";
              language-servers = ["vscode-json-language-server"];
              formatter = {
                command = "prettier";
                args = ["--parser" "json"];
              };
              auto-format = true;
            }

            # Markdown
            {
              name = "markdown";
              language-servers = ["marksman"];
              formatter = {
                command = "prettier";
                args = ["--parser" "markdown"];
              };
              auto-format = false; # avoids reformatting prose mid-thought
            }

            # Bash / Shell
            {
              name = "bash";
              language-servers = ["bash-ls"];
              formatter = {
                command = "shfmt";
                args = ["-i" "2" "-"];
              };
              auto-format = true;
            }
          ];
        };
      };
    })
  ];
}
