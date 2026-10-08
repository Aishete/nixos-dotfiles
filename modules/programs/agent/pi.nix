# Pi coding agent (@earendil-works/pi-coding-agent) — minimal coding-agent
# harness (read/write/edit/bash tools). The binary comes from nixpkgs
# (added in hosts/nixwiz/host-packages.nix); user config lives in
# ~/.pi/agent — pi's agent directory (docs: packages/coding-agent/docs/
# configuration.md, models.md, settings.md, skills.md, mcp.md, tag v1.0.3).
#
# Provider: Ollama Cloud WITHOUT a local daemon. The OpenAI-compatible
# layer is https://ollama.com/v1 (NOT /api — that prefix is Ollama's native
# API and 404s on chat paths; verified against docs.ollama.com/integrations/pi).
#
# API key: no plaintext credential in these files. models.json apiKey
# supports a leading "!command" that pi executes at request time (never
# cached), so the existing OLLAMA_API_KEY is pulled from ~/.hermes/.env
# on demand.
#
# settings.json is SEEDED ONLY on first activation (the activation script
# checks existence). After that pi owns the file: in-app Ctrl+S in /model
# writes defaults there, and a rebuild must not clobber them. To re-seed,
# delete ~/.pi/agent/settings.json and rebuild.
#
# AGENTS.md and mcp.json are Nix-managed (pi never rewrites them in-app).
# The skills directory is a farm of per-category symlinks into Hermes's
# library (~/.hermes/skills) — pi discovers skills recursively from it.
{ ... }: {
  home-manager.sharedModules = [
    (
      { pkgs, lib, ... }:
      let
        piSettingsSeed = pkgs.writeText "pi-settings-seed.json" ''
          {
            "defaultProvider": "ollama-cloud",
            "defaultModel": "glm-5.3-flash"
          }
        '';
      in
      {
        # Custom provider + every cloud model available to this account
        # (GET https://ollama.com/v1/models on 2026-10-08 — list is
        # plan/tier dependent; refresh it if the model lineup changes).
        home.file.".pi/agent/models.json".text = ''
          {
            "providers": {
              "ollama-cloud": {
                "baseUrl": "https://ollama.com/v1",
                "api": "openai-completions",
                "apiKey": "!sed -n 's/^OLLAMA_API_KEY=//p' /home/archdev/.hermes/.env | head -1 | tr -d '\"'",
                "models": [
                  { "id": "deepseek-v4-pro:0813" },
                  { "id": "deepseek-v4.1-flash" },
                  { "id": "gemma4:31b" },
                  { "id": "glm-5.2" },
                  { "id": "glm-5.3" },
                  { "id": "glm-5.3-flash" },
                  { "id": "gpt-oss:120b" },
                  { "id": "gpt-oss:20b" },
                  { "id": "kimi-k2.6" },
                  { "id": "kimi-k2.7-code" },
                  { "id": "kimi-k3" },
                  { "id": "minimax-m2.7" },
                  { "id": "minimax-m3" },
                  { "id": "mistral-large-3:675b" },
                  { "id": "mistral-large-4" },
                  { "id": "nemotron-3-nano:30b" },
                  { "id": "nemotron-3-super" },
                  { "id": "nemotron-3-ultra" }
                ]
              }
            }
          }
        '';

        # Standing instructions for pi — distilled from Hermes's SOUL.md +
        # WORK.md + verification-before-completion discipline. Nix-managed:
        # edit THIS file to change pi's behavior, then rebuild.
        home.file.".pi/agent/AGENTS.md".text = ''
          # PI — standing instructions (Nix-managed: ~/NixOS/modules/programs/agent/pi.nix)

          ## Who you work for
          One user, not a generic agent. A NixOS tinkerer: the whole machine runs
          from a flake at ~/NixOS; NvChad config at ~/.config/nvim is a hand-editable
          git repo. He builds open-data infrastructure (CKAN / ODC stack, odm-core),
          competes in Kaggle skill-lift challenges, and operates a small fleet of
          agents and bots (Hermes, gortex, opencode workers, Telegram pipelines,
          cron jobs). Technical, skeptical, busy. He checks claims against primary
          sources. He likes control: of his configs, his approvals, his git.

          ## Hard rules
          - NEVER run rm -rf, rm -fr, rm -r -f, rm -f -r, or any destructive
            delete chain. If cleanup is needed, leave temp files and ask.
          - git push ONLY when explicitly asked. Never commit unrelated staged
            files; propose a logical commit grouping and let him confirm.
          - Never print, echo, or write API keys anywhere. Keys live in
            ~/.hermes/.env and are resolved by tooling — not your business.
          - NEVER fabricate command output. If a tool fails or is blocked,
            report the real error and try a different approach.
          - No completion claim without fresh evidence from an actual run.
          - Diagnose from real errors before changing anything. No guessing.
          - He reviews before approving: explain and offer; do not auto-apply
            system/config changes unless he asked for the change.

          ## Workflow (Hermes conventions)
          - Plan trade-offs first; he decides before the change happens.
          - Overview first, then details on request.
          - Give exact commands and paths; he often fixes code himself.
          - Every report answers: what changed, what you verified with which
            command, what remains risky.

          ## Day job (ODM / ODC)
          Open-data platform on CKAN 2.10 (odm-core / ODC). Active dev stack:
          dev_2.10_test3; REAL compose file is docker-compose.dev.yml (bare
          `make build` follows a symlink and builds PREPROD — a false gate;
          always invoke the dev compose explicitly). Registry access works ONLY
          via the -ewmi host. odm-core is a submodule holding the extensions.
          Daily work: extension development, theming, Khmer i18n, deployments.
          Relevant skills live under the ckan-* skill categories.

          ## Frameworks in reach
          - skills/: the Hermes skill library, symlinked per category. Skills
            are directories with SKILL.md; load one with /skill:name when a
            task matches (also try: nixos, software-development, devops,
            research, web-development, process). The .archive category is dead
            history — never take a .archive skill over a live one.
          - gortex MCP: code-graph intelligence over tracked repos. Consult it
            (search/read/relations, change impact) before larger edits in
            tracked repositories.
          - This directory (~/.pi/agent) is pi's agent home; sessions live in
            sessions/. Config here is deployed by Nix rebuilds.
        '';

        # MCP servers available in every project. gortex binds the repo by the
        # spawned child's cwd (same trap as in Hermes's module), and no cwd is
        # set here — so gortex inherits pi's working directory = the project
        # pi is running in. That is the correct per-project behavior.
        home.file.".pi/agent/mcp.json".text = ''
          {
            "mcpServers": {
              "gortex": {
                "command": "/home/archdev/.local/bin/gortex",
                "args": [ "mcp" ]
              }
            }
          }
        '';

        # Seed default provider/model once; pi owns the file afterwards.
        home.activation.seedPiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e "$HOME/.pi/agent/settings.json" ]; then
            mkdir -p "$HOME/.pi/agent"
            cp ${piSettingsSeed} "$HOME/.pi/agent/settings.json"
            chmod 0644 "$HOME/.pi/agent/settings.json"
          fi
        '';

        # Skills symlink farm: one symlink per ACTIVE top-level category from
        # ~/.hermes/skills into ~/.pi/agent/skills. .archive is excluded ON
        # PURPOSE — archived skills reuse live skill names, and pi keeps the
        # FIRST discovered skill on a name collision (the archive would
        # shadow the live version). Creation-only: stale links (a category
        # later deleted from Hermes) are left as harmless dangling symlinks
        # rather than auto-deleted (the user's no-delete rule).
        home.activation.seedPiSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.pi/agent/skills"
          for cat in "$HOME"/.hermes/skills/*; do
            name="''${cat##*/}"
            if [ "$name" != ".archive" ] && [ -d "$cat" ]; then
              ln -sfn "$cat" "$HOME/.pi/agent/skills/$name"
            fi
          done
        '';
      }
    )
  ];
}
