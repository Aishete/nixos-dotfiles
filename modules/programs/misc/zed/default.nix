{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    userSettings = {
      when_closing_with_no_tabs = "platform_default";
      ui_font_family = "Iosevka Nerd Font";
      buffer_font_family = "Iosevka Nerd Font";
      base_keymap = "JetBrains";
      vim_mode = true;
      theme = "Transparent Prism - Frost";
      icon_theme = {
        mode = "light";
        light = "Zed (Default)";
        dark = "Zed (Default)";
      };
      project_panel = {
        dock = "left";
      };
      outline_panel = {
        dock = "left";
      };
      collaboration_panel = {
        dock = "left";
      };
      agent = {
        dock = "right";
        favorite_models = [];
        model_parameters = [];
      };
      git_panel = {
        dock = "right";
      };
      agent_servers = {
        "hermes-agent" = {
          type = "custom";
          command = "hermes";
          args = ["acp"];
        };
      };
      context_servers = {
        "gortex" = {
          source = "custom";
          args = ["mcp"];
          command = "gortex";
          env = {
            GORTEX_INDEX_WORKERS = "8";
          };
        };
      };
    };
    extensions = [
      "nix"
      "toml"
      "lua"
    ];
  };
}
