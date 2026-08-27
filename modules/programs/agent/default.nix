# Hermes Agent — NixOS system-level installation
#
# Provides hermes CLI system-wide, systemd service, and web dashboard.
# User config lives in ~/.hermes/ (untouched by NixOS).
{config, ...}: {
  services.hermes-agent = {
    enable = true;

    # Run as the real user — don't create a separate "hermes" system user.
    # This makes the service use /home/archdev/.hermes as HERMES_HOME.
    createUser = false;
    user = "archdev";
    group = "users";
    stateDir = "/home/archdev";

    # LLM providers
    # Default: OpenCode Go (mimo-v2.5)
    # Ollama Cloud available via profile switch or --provider flag
    # Override per-profile via ~/.hermes/config.yaml or --profile flag
    settings = {
      model = {
        provider = "opencode-go";
        default = "hy3";
        base_url = "https://opencode.ai/zen/go/v1";
      };
      providers = {
        ollama-cloud = {
          base_url = "https://ollama.com/v1";
        };
      };
      delegation = {
         provider = "ollama-cloud";
         model = "deepseek-v4-flash:0731";
         base_url = "https://ollama.com/v1";
         max_concurrent_children = 2;
         api_key = "\${OLLAMA_API_KEY}";
         reasoning_effort = "high"; #valid values: none/low/medium/high/max;
       };

      display = {
        pet = {
          enabled = false;
          slug = "homelander";
          render_mode = "auto";
        };
      };
      approvals = {
         mode = "manual";
         cron_mode = "deny";
         deny = [
           "rm -rf *"
           "rm -fr "
           "rm -r -f"
           "rm -f -r*"
         ];
       };
      mcp_servers = {
        blender = {
          args = [ "blender-mcp" ];
          command = "uvx";
          connect_timeout = 60;
          timeout = 120;
        };
        obsidian = {
          enabled = true;
          headers = {
            Authorization = "Bearer \${MCP_OBSIDIAN_API_KEY}";
          };
          url = "https://syncc.scriptwiz.fun/mcp";
        };
        gortex = {
          command = "/home/archdev/.local/bin/gortex";
          args = [ "mcp" ];
          connect_timeout = 60;
          timeout = 120;
        };
        open-interpreter = {
          command = "/home/archdev/.local/bin/interpreter";
          args = [ "mcp-server" ];
          connect_timeout = 60;
          timeout = 120;
        };
        mempalace = {
          enabled = true;
          command = "docker";
          args = [ "run" "-i" "--rm" "-v" "mempalace-data:/data" "ghcr.io/mempalace/mempalace" ];
          connect_timeout = 60;
          timeout = 120;
        };
      };
      platform_toolsets = {
        cli = [
          "browser"
          "clarify"
          "code_execution"
          "cronjob"
          "delegation"
          "file"
          "image_gen"
          "memory"
          "messaging"
          "session_search"
          "skills"
          "terminal"
          "todo"
          "tts"
          "vision"
          "web"
          "yuanbao"
          "spotify"
        ];
        telegram = [
          "browser"
          "clarify"
          "code_execution"
          "cronjob"
          "delegation"
          "file"
          "image_gen"
          "memory"
          "messaging"
          "session_search"
          "skills"
          "terminal"
          "todo"
          "tts"
          "vision"
          "web"
          "spotify"
        ];
      };
    };

    # Add hermes to system-wide PATH and export HERMES_HOME
    addToSystemPackages = true;
  };

  # Load API keys from ~/.hermes/.env for the hermes-agent systemd service
  systemd.services.hermes-agent.serviceConfig.EnvironmentFile = "%h/.hermes/.env";
}
