# NixOS Config Tidy-Up — Results (2026-10-15/16)

Orchestrated from docs/plans/2026-10-15-config-tidy-up.md. All user gates honored.

## Commits (in order, branch nixwiz)
| sha | subject |
|---|---|
| 265df08 | feat(fonts): add Caelusevka font families |
| 00bf8f8 | chore: bump flake.lock |
| b820638 | feat(agent): update pi agent module |
| dcfcff6 | feat(pkgs): add typescript-language-server overlay package |
| e861162 | chore: untrack gortex sidecar DB (gitignored) |
| 474d346 | chore: remove upstream template leftovers (RICE_RESEARCH, who-am-i.html, .github/) |
| 1d16b16 | chore(hosts): remove broken template hosts (Default, script — both un-buildable) |
| c602b37 | chore(pkgs): remove dead packages, orphaned patch and pokego |
| bd69d9a | chore(pkgs): remove unused pokego derivation |
| 29d9ed8 | chore(flake): drop commented-out input block |
| e9701f4 | refactor(wallpapers): move library to ~/Pictures, rewire picker to runtime path |
| 331eff4 | feat(security): migrate nix profile pentest suite into flake |
| 2fb4f75 | fix(security): skip netexec broken pin chain, mark anyio test-skip as bump-stale |
| 5760507 | refactor(marimo): drop SQL/charts/LSP extras (user-approved) |
| 6368d80 | update broswer remove unuse app (user's own overnight session) |
| fa2aba7..b7b5c29 | 6 test-skip fixes: httpx2, openai, mcp, pylsp, jupyter-server, jupytext (marimo chain — now INERT after the trim + extensions removal) |
| 571143f | feat(apps): libreoffice from stable hydra cache (prebuilt) |
| b6961f2 | fix(overlays): urwid noPytest (real line after a comment-only miss) |
| cc19018 | fix(overlays): drop GLOBAL pythonPackagesExtensions |

## Key numbers
- Repo: 1.7G -> 994M total; worktree 60M (goal <100M). .git history 918M = old wallpapers (optional history rewrite to shrink further)
- Wallpaper pool in store per build: 725M -> 2.2M (269 files moved to ~/Pictures/wallpapers)
- nix profile: 47 entries -> 1 (hermes desktop only); 46 tools now in flake config
- System closure baseline: 32.5 GiB (dup: electron x4 4.9G, ffmpeg x9 2.9G, python3 x12 2.7G, nodejs x8 2.1G)
- Disk: 97% -> 88% via docker prunes (6.5G) + GCs (10.2G fresh, 2.3G profile) + user sudo cleanups (~20G freed overnight)

## Pitfall wisdom captured (for the skill library)
1. `git commit <pathspec>` resurrects staged DELETIONS from the worktree — repaired via temp-index plumb (GIT_INDEX_FILE + update-index --force-remove + write-tree + commit-tree).
2. A global pythonPackagesExtensions re-hashes every python drv in every set => hydra prebuilts stop substituting => full source rebuilds. Global extensions = self-inflicted cache misses.
3. GC during a disk crisis deletes the very paths a re-run needs (pin the in-progress toplevel with -o before GCing).
4. nix build <drv> (no ^out) only realizes the .drv file — silent instant success that tests nothing.
5. `nix profile list` colorizes even when piped — strip ANSI codes before parsing.
6. Wedged builds: locks frozen >8 min + no builder procs + no stderr = dead cache conn; kill WRAPPER only, re-run.

## Remaining / next
- [ ] build7 (detached, in progress): 134 mostly-pin-miss source builds (firefox-158, qgis/gdal/pdal, mitmproxy family, playwright) — will take 1.5-3h; re-run if wedged
- [ ] After build: run ~/NixOS/docs/tidy-verify.sh
- [ ] USER: sudo nixos-rebuild switch --flake ~/NixOS#nixwiz
- [ ] USER spot-checks: wallpaper picker (SUPER+SHIFT+W), nmap/msfconsole/nuclei, marimo (AI+base still work; SQL/charts/pylsp REMOVED), LibreOffice (now 25.2.6.2 stable prebuilt), ghostty/qutebrowser removals
- [ ] Later agents (already approved): ha-hermes.txt (hermes follows our nixpkgs, ~2.2G), el-electron.txt (github-desktop -> electron 44, ~2.4G)
- [ ] Optional: nix profile now holds only hermes "desktop" — decide keep/install via hermes reference instead
- [ ] Optional: netexec re-install from old registry rev once convenient (nix profile install flake:nixpkgs#netexec)
- [ ] Optional: history rewrite if .git bloat matters
