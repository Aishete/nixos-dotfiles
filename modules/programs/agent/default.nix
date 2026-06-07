# Hermes Agent — NixOS system-level installation
#
# Provides hermes CLI system-wide, systemd service, and web dashboard.
# User config lives in ~/.hermes/ (untouched by NixOS).
{config, ...}: {
  services.hermes-agent = {
    enable = true;

    # LLM provider — uses OpenCode Go by default (matching user's setup)
    # Override per-profile via ~/.hermes/config.yaml or --profile flag
    settings = {
      model = {
        provider = "opencode-go";
        default = "deepseek-v4-flash";
        base_url = "https://opencode.ai/zen/go/v1";
      };

      # Web dashboard configuration
      web = {
        enable = true;
        port = 9119;
        host = "127.0.0.1";  # Local only — use 0.0.0.0 for network access
      };
    };

    # Add hermes to system-wide PATH
    addToSystemPackages = true;
  };
}
