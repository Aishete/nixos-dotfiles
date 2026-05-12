# FIXME: sops key mismatch — secrets file has key "DEEPSEEK_API_KEY" but
# sops.secrets."hermes-env" expects a key named "hermes-env".
# Fix: either rename the key in secrets/hermes-env.yaml to "hermes-env"
# or change secrets."hermes-env" to secrets."DEEPSEEK_API_KEY" (and update
# the environmentFiles path reference below).
#
# {config, ...}: {
#   sops = {
#     age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
#     defaultSopsFile = ../../../secrets/hermes-env.yaml;
#     secrets."hermes-env" = {};
#   };
#
#   services.hermes-agent = {
#     enable = true;
#
#     # Change this to DeepSeek
#     settings = {
#       model = {
#         provider = "deepseek";
#         default = "deepseek-v4-pro"; # or "deepseek-v4-flash"
#         base_url = "https://api.deepseek.com/v1";
#       };
#     };
#
#     # Your secrets file needs DEEPSEEK_API_KEY instead
#     environmentFiles = [config.sops.secrets."hermes-env".path];
#     addToSystemPackages = true;
#   };
# }
{config, ...}: {}
