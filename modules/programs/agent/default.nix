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

    # LLM provider — uses OpenCode Go by default (matching user's setup)
    # Override per-profile via ~/.hermes/config.yaml or --profile flag
    settings = {
      model = {
        provider = "opencode-go";
        default = "mimo-v2.5";
        base_url = "https://opencode.ai/zen/go/v1";
      };
      platform_toolsets = {
        cli = [
          "browser" "clarify" "code_execution" "cronjob" "delegation"
          "file" "image_gen" "memory" "messaging" "session_search"
          "skills" "terminal" "todo" "tts" "vision" "web" "yuanbao"
          "spotify"
        ];
        telegram = [
          "browser" "clarify" "code_execution" "cronjob" "delegation"
          "file" "image_gen" "memory" "messaging" "session_search"
          "skills" "terminal" "todo" "tts" "vision" "web"
          "spotify"
        ];
      };
    };

    # Add hermes to system-wide PATH and export HERMES_HOME
    addToSystemPackages = true;
  };
}
