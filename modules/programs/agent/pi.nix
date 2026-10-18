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
# Per-model metadata (contextWindow / reasoning / thinkingLevelMap / input /
# cost) verified 2026-10-08, three sources:
#   - contextWindow: POST https://ollama.com/api/show (model_info.context_length)
#   - thinkingLevelMap: live sweep of 90 reasoning_effort calls on
#     ollama.com/v1/chat/completions. Findings: ollama accepts "none" to
#     DISABLE thinking; "off" is broken (clamps low or HTTP 400); gpt-oss
#     cannot disable at all ("none" THINKS MORE than minimal; only
#     minimax-m2.7's floor is "none" since it always thinks). Refresh by
#     re-running the sweep, not by /api/show's thinking values (unreliable).
#   - cost: https://ollama.com/pricing, $ per 1M tokens (pi uses the same
#     unit; cacheWrite is NOT published there — set equal to input rate as
# granularity kept at OpenAI-spec levels) and minimax-m2.7 (ALWAYS thinks —
# "none" is merely its cheapest floor) and mistral-large-3:675b (never thinks —
# no reasoning entries).
#
# Cached-input price missing on ollama.com/pricing for mistral-large-3:675b and
# nemotron models -> their cacheRead equals the input rate (pessimistic, no fake
# discount). gpt-oss:20b cacheRead 0.035 is as published (not a typo).
#
# thinkingLevelMap encodes pi's 7 levels -> the ollama values each model
# actually accepts. Standard map below ("none" disables, low/high/max hold)
# is used by every thinking model EXCEPT gpt-oss ("none" there THINKS MORE
# than minimal, so off->minimal and native xhigh/medium granularity is kept)
# and minimax-m2.7 (always thinks — "none" is merely its cheapest observed
# floor) and mistral-large-3:675b (never thinks — no reasoning entries).
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
      { pkgs, lib, config, ... }:
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
                  { "id": "deepseek-v4-pro:0813", "name": "DeepSeek V4 Pro",
                    "contextWindow": 1048576, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 1.32, "output": 3.96, "cacheRead": 0.044, "cacheWrite": 1.32 } },
                  { "id": "deepseek-v4.1-flash", "name": "DeepSeek V4.1 Flash",
                    "contextWindow": 1048576, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.30, "output": 1.20, "cacheRead": 0.006, "cacheWrite": 0.30 } },
                  { "id": "gemma4:31b", "name": "Gemma 4 31B",
                    "contextWindow": 262144, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.14, "output": 0.40, "cacheRead": 0.05, "cacheWrite": 0.14 } },
                  { "id": "glm-5.2", "name": "GLM 5.2",
                    "contextWindow": 1048576, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 1.40, "output": 4.40, "cacheRead": 0.26, "cacheWrite": 1.40 } },
                  { "id": "glm-5.3", "name": "GLM 5.3",
                    "contextWindow": 1048576, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 1.40, "output": 4.40, "cacheRead": 0.26, "cacheWrite": 1.40 } },
                  { "id": "glm-5.3-flash", "name": "GLM 5.3 Flash",
                    "contextWindow": 1048576, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.15, "output": 0.50, "cacheRead": 0.03, "cacheWrite": 0.15 } },
                  { "id": "gpt-oss:120b", "name": "GPT-OSS 120B",
                    "contextWindow": 131072, "reasoning": true,
                    "thinkingLevelMap": { "off": "minimal", "minimal": "minimal", "low": "low", "medium": "medium", "high": "high", "xhigh": "xhigh", "max": "max" },
                    "cost": { "input": 0.15, "output": 0.60, "cacheRead": 0.014, "cacheWrite": 0.15 } },
                  { "id": "gpt-oss:20b", "name": "GPT-OSS 20B",
                    "contextWindow": 131072, "reasoning": true,
                    "thinkingLevelMap": { "off": "minimal", "minimal": "minimal", "low": "low", "medium": "medium", "high": "high", "xhigh": "xhigh", "max": "max" },
                    "cost": { "input": 0.07, "output": 0.30, "cacheRead": 0.035, "cacheWrite": 0.07 } },
                  { "id": "kimi-k2.6", "name": "Kimi K2.6",
                    "contextWindow": 262144, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.95, "output": 4.00, "cacheRead": 0.16, "cacheWrite": 0.95 } },
                  { "id": "kimi-k2.7-code", "name": "Kimi K2.7 Code",
                    "contextWindow": 262144, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.95, "output": 4.00, "cacheRead": 0.19, "cacheWrite": 0.95 } },
                  { "id": "kimi-k3", "name": "Kimi K3",
                    "contextWindow": 1048576, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 3.00, "output": 15.00, "cacheRead": 0.30, "cacheWrite": 3.00 } },
                  { "id": "minimax-m2.7", "name": "MiniMax M2.7",
                    "contextWindow": 196608, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.30, "output": 1.20, "cacheRead": 0.06, "cacheWrite": 0.30 } },
                  { "id": "minimax-m3", "name": "MiniMax M3",
                    "contextWindow": 512000, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.60, "output": 2.40, "cacheRead": 0.12, "cacheWrite": 0.60 } },
                  { "id": "mistral-large-3:675b", "name": "Mistral Large 3 675B",
                    "contextWindow": 262144, "input": ["text", "image"],
                    "cost": { "input": 0.50, "output": 1.50, "cacheRead": 0.50, "cacheWrite": 0.50 } },
                  { "id": "mistral-large-4", "name": "Mistral Large 4",
                    "contextWindow": 1048576, "reasoning": true, "input": ["text", "image"],
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.68, "output": 2.09, "cacheRead": 0.07, "cacheWrite": 0.68 } },
                  { "id": "nemotron-3-nano:30b", "name": "Nemotron 3 Nano",
                    "contextWindow": 262144, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.06, "output": 0.24, "cacheRead": 0.06, "cacheWrite": 0.06 } },
                  { "id": "nemotron-3-super", "name": "Nemotron 3 Super",
                    "contextWindow": 262144, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.015, "output": 0.60, "cacheRead": 0.015, "cacheWrite": 0.015 } },
                  { "id": "nemotron-3-ultra", "name": "Nemotron 3 Ultra",
                    "contextWindow": 262144, "reasoning": true,
                    "thinkingLevelMap": { "off": "none", "minimal": "low", "low": "low", "medium": "high", "high": "high", "xhigh": "max", "max": "max" },
                    "cost": { "input": 0.10, "output": 3.00, "cacheRead": 0.10, "cacheWrite": 0.10 } }
                ]
              }
            }
          }
        '';

        # s1gate-pi extension (source of truth: ~/projects/s1gate repo,
        # committed: da245e5/adfd6ad). Out-of-store symlink: edits to the
        # repo take effect on next pi start WITHOUT a rebuild.
        home.file.".pi/agent/extensions/s1gate-pi.ts".source =
          config.lib.file.mkOutOfStoreSymlink
            "/home/archdev/projects/s1gate/pi-extension/s1gate-pi.ts";

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

          ## Division of labor (2026-10-17)
          You (pi) are the DAILY CODING agent: write, fix, test, refactor,
          ship in the project repos. Deep research, vault/OSINT work, bot
          operations and planning reports belong to Hermes (the orchestrator
          agent he runs separately) — if a task is really research, say so
          and let him route it. Evaluation of your runs also lives
          outside pi (post-hoc session review by Hermes); just work normally.

          ## Day job (ODM / ODC)
          Open-data platform on CKAN 2.10 (odm-core / ODC). Active dev stack:
          dev_2.10_test3; REAL compose file is docker-compose.dev.yml (bare
          `make build` follows a symlink and builds PREPROD — a false gate;
          always invoke the dev compose explicitly). Registry access works ONLY
          via the -ewmi host. odm-core is a submodule holding the extensions.
          Daily work: extension development, theming, Khmer i18n, deployments.
          Relevant skills live under the ckan-* skill categories.

          ## Frameworks in reach
          - skills/: the CURATED coding subset of the Hermes skill library
            (symlinked per category; research/non-coding categories were
            moved to ~/.pi/agent/skills-disabled — re-enable by asking the
            user to move a category back). Skills are directories with
            SKILL.md; load one with /skill:name when a task matches
            (try: nixos, software-development, devops, process, testing,
            debugging, refactoring, github, web-development,
            code-intelligence, gortex-workflow-patterns, typesafe-ai,
            understand-*). The .archive category is dead history — never
            take a .archive skill over a live one.
          - GLOSSARY.md: if the repo has one, read it — it is the codebase's
            domain glossary; respect its terms in test names, PRs and API
            naming.
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
        # shadow the live version). CREATION-ONLY (v2 fork-on-edit, 2026-10-
        # 08): categories already materialized as real dirs by tools/
        # pi-skill-fork.sh (s1gate repo) are NEVER re-linked to whole-
        # category symlinks — ln -sfn would corrupt a forked farm. A category
        # left as a dangling link (target deleted upstream) is still
        # refreshed here (no-delete rule kept: links, not content).
        # CURATION (2026-10-17): categories parked in ~/.pi/agent/skills-disabled
        # (research/non-coding set, moved by hand) are SKIPPED — the seed must
        # not resurrect them on rebuild (v3).
        home.activation.seedPiSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "$HOME/.pi/agent/skills" "$HOME/.pi/agent/skills-disabled"
          for cat in "$HOME"/.hermes/skills/*; do
            name="''${cat##*/}"
            if [ "$name" != ".archive" ] && [ -d "$cat" ]; then
              if [ -e "$HOME/.pi/agent/skills-disabled/$name" ]; then
                : # parked in skills-disabled — curation keeps it out of the farm
              elif [ ! -e "$HOME/.pi/agent/skills/$name" ] && [ ! -L "$HOME/.pi/agent/skills/$name" ]; then
                ln -s "$cat" "$HOME/.pi/agent/skills/$name"
              fi
            fi
          done
        '';
      }
    )
  ];
}
