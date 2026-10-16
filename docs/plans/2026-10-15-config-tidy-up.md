# NixOS Config Tidy-Up — Implementation Plan

**Date:** 2026-10-15
**Repo:** `/home/archdev/NixOS` (flake, git, live host = `nixwiz`)
**Skills:** `nixos` (~/.pi/agent/skills/nixos/nixos), `writing-plans`, `verification-before-completion`
**Golden rule:** nothing is deleted or committed without an explicit user gate. Each task ends with a verifiable state.

---

## Baseline (measured 2026-10-15)

| Item | State |
|---|---|
| Repo size | 1.7G total — `modules/themes/wallpapers` = **725M, 272 tracked image files** |
| Git index | **Mixed**: staged `flake.lock`, `fonts.nix` + 16 TTFs, `agent/pi.nix`, `pkgs/default.nix`, `pkgs/typescript-language-server/*`; unstaged `dns.nix` |
| Tracked-but-ignored | `.gortex/sidecar.sqlite{,-shm,-wal}` — in .gitignore but still tracked (added before the rule) |
| Top-level stray files | `RICE_RESEARCH_2026-08.md`, `who-am-i.html`, `.github/FUNDING.yml` + upstream README + 5 preview PNGs (template fork leftovers) |
| Hosts | 3 wired: `Default`, `nixwiz` (live), `script` — `Default`/`script` look like upstream template hosts |
| flake.nix inputs | All live inputs verified referenced in modules ✓; large commented-out input block (noctalia, doom-config, nixvim, plasma-manager, zen-browser, neovim) |
| Overlays | `vesktop`/`discord` overrides + `patches/ananicy-cpp-cstring.patch` (usage unverified) |
| **Closure duplication (live system, 32.5 GiB)** | electron ×4 = 4.9 GB (signal-desktop→e44.5.1, github-desktop→e43.7.7); ffmpeg-headless ×9 = 2.9 GB; python3 ×12 = 2.7 GB (3 real builds + 8 per-app envs); nodejs ×8 = 2.1 GB (node 24+26); gcc ×15 = 1.2 GB; icu4c/glibc/curl/openssl/zlib ≈ 2.4 GB combined |
| **`nix profile` bloat** | 46 packages (pentest suite: amass→whois + hermes `packages.desktop`), **9.9 GiB closure**, 326 bins in `~/.nix-profile/bin`, pinned to OLD registry rev `4975466d…` (channel nixpkgs, NOT the flake's pin) — carries its own python/gcc/openssl at old versions |
| Correctly ignored | `result*`, `.crush/`, `*.rrdata`, dev-shell lock files |

**Skills-derived pitfalls that apply (from `nixos` SKILL.md):**
1. Pre-staged index sweep — `git add X && git commit` commits the WHOLE index. Use pathspec form: `git commit <path> -m`.
2. Dry-run is a false green — final proof requires realizing the toplevel (`nix build ... --no-link -o /tmp/tl`), not `--dry-run`.
3. Dry-run prints to **stderr** — capture `2>/tmp/err`, count derivations there.
4. Piped nix commands mask exit codes — `set -o pipefail` in the SAME command string.
5. Untracked files are invisible to the flake — `git add -N` new files before any eval.
6. After unstaging, flake-referenced files must be re-added or rebuilds break.
7. Verify every host/branch, not just the default.
8. Never `git push` unprompted; commit groups confirmed with user first.

---

## Task 0 — Safety snapshot & warning baseline (read-only)

Steps:
1. `cd ~/NixOS && git rev-parse HEAD > /tmp/tidy-baseline.txt && du -sh . >> /tmp/tidy-baseline.txt`
2. `readlink -f /run/current-system >> /tmp/tidy-baseline.txt`
3. Capture eval warnings (stderr!):
   ```bash
   cd ~/NixOS && nix build .#nixosConfigurations.nixwiz.config.system.build.toplevel \
     --dry-run >/tmp/eval-nixwiz.out 2>/tmp/eval-nixwiz.err; echo "EXIT=$?"
   grep -c -i warning /tmp/eval-nixwiz.err
   ```
4. Repeat for `Default` and `script` (they must eval cleanly anyway if kept).
5. Grep warning names → match against `references/nixpkgs-warning-fixes.md` in the nixos skill.

**Deliverable:** `/tmp/tidy-baseline.txt` + warning list per host.
**Verification:** command outputs shown verbatim. No changes to the repo.

---

## Task 1 — Git index hygiene: land the in-flight work

**User gate first:** show `git status --short` + per-group `git diff --stat`; confirm the grouping before any commit.

Proposed conventional-commit groups (pathspec commits, one at a time, checking the index before each):

| # | Files | Commit message |
|---|---|---|
| 1 | `modules/core/fonts.nix` + `modules/core/fonts/caelusevka*/*.ttf` | `feat(fonts): add Caelusevka font families` |
| 2 | `flake.lock` | `chore: bump flake.lock` |
| 3 | `modules/programs/agent/pi.nix` | `feat(agent): update pi agent module` |
| 4 | `pkgs/default.nix`, `pkgs/typescript-language-server/*` | `feat(pkgs): add typescript-language-server overlay package` |
| 5 | `modules/core/dns.nix` — **review unstaged diff with user first** (may be WIP; if unfinished, leave it and note it) | `fix(core): dns ...` or skip |
| 6 | `git rm --cached .gortex/sidecar.sqlite .gortex/sidecar.sqlite-shm .gortex/sidecar.sqlite-wal` | `chore: untrack gortex sidecar DB (gitignored)` |

Method per commit (avoids pitfall #1):
```bash
git status --short                 # confirm what's staged NOW
git add <paths>
git commit <paths> -m "..."        # pathspec form — index sweep-proof
```

**Verification:**
- `git status --short` → only intended leftovers remain
- `git log --oneline -8` → clean grouped history
- `nix build .#nixosConfigurations.nixwiz.config.system.build.toplevel --dry-run 2>/tmp/e.err` → EXIT=0 (nothing the flake references got unstaged — pitfall #6)
- **No push.**

---

## Task 2 — Top-level clutter sweep

**User gate:** present the list, user picks keep/move/delete per item.

| File | Evidence | Proposal |
|---|---|---|
| `RICE_RESEARCH_2026-08.md` | research notes | move to `docs/research/` (or delete) |
| `who-am-i.html` | stray personal page | move to `docs/` or delete |
| `.github/FUNDING.yml`, `.github/README.md`, `.github/assets/preview*.png` | upstream template identity (fork origin) | delete unless user's fork identity wants them |
| `install.sh`, `live-install.sh` | bootstrap tooling | **keep** |
| `.gortex/`, `.crush/`, `result`, `result-1` | ignored already | no git action; optionally delete `result*` symlinks from disk |

If files move: `mkdir -p docs/research && git mv <file> docs/research/` then commit `chore: move research notes out of repo root`.
If deleting: `git rm` + commit `chore: remove upstream template leftovers`.

**Verification:** `git status --short` clean; `git ls-files | grep -E "who-am-i|RICE_RESEARCH"` → empty (if deleted/moved).

---

## Task 3 — Host audit: are `Default` and `script` real?

Facts to gather (read-only):
1. `diff -r hosts/Default hosts/nixwiz` and `diff -r hosts/script hosts/nixwiz` → how much is duplicated boilerplate?
2. Read `hosts/*/hardware-configuration.nix` — real machine UUIDs = real host; generic = template.
3. Ask user: ever built on other machines?

**User gate — pick one:**
- **(a) Remove dead hosts:** delete `hosts/Default hosts/script` + the two `mkHost` lines in `flake.nix` → commit `chore(hosts): remove unused template hosts`.
- **(b) Keep as templates:** dedupe instead — if `host-packages.nix` is ~identical across hosts, extract shared packages into `modules/core/packages.nix` (already exists per skill) and keep only host-specific bits. Commit `refactor(hosts): deduplicate host packages`.

**Verification:** dry-run eval of every surviving host (pitfall #7):
```bash
for h in nixwiz; do nix build .#nixosConfigurations.$h.config.system.build.toplevel --dry-run >/dev/null 2>/tmp/ev-$h.err; echo "$h EXIT=$?"; done
```

---

## Task 4 — Wallpapers: 725M / 272 files (biggest win, needs a strategy decision)

Facts to gather (read-only):
1. Which wallpapers are *referenced*: `grep -rn "defaultWallpaper" hosts/*/variables.nix modules/themes` — how many of the 272 are actually named?
2. How the pool is consumed at runtime: read `modules/scripts/launcher.nix` (~line 96-102: canonical `~/.local/share/wallpapers/selected.webp`) + hyprland rice modules — does the pool get linked into the system (`xdg.dataFile` / store path), i.e. are "unused" wallpapers part of the user's runtime library?
3. Exact duplicate scan (safe win regardless of strategy):
   ```bash
   git ls-files -z modules/themes/wallpapers | xargs -0 sha256sum | sort | awk '{print $1}' | uniq -d | wc -l
   ```
4. Size distribution: `git ls-files -z modules/themes/wallpapers | xargs -0 du -k | sort -rn | head` — how many > 5M?

**User gate — strategy (present facts first):**

| Option | Action | Effect |
|---|---|---|
| **A. Safe trim** | delete exact duplicates; re-encode >5M PNGs to webp/jxl (only where visually lossless); keep all remaining | ~10-30% size cut, zero behavior change |
| **B. Split the pool** | keep referenced/default wallpapers in-repo; move the library to `~/Pictures/wallpapers/` + wire via symlink or flake input; update launcher path | repo 1.7G → <100M |
| **C. Keep** | leave as-is | 0 |

Commit: `chore(wallpapers): remove N exact duplicates` / `refactor(wallpapers): move library out of git`.

**Verification (this touches the live desktop — real build, not dry-run, pitfall #2):**
```bash
nix build .#nixosConfigurations.nixwiz.config.system.build.toplevel --no-link -o /tmp/tl-nixwiz 2>/tmp/build-nixwiz.err
echo EXIT=$?
# wallpaper still lands in the built tree:
find /tmp/tl-nixwiz -maxdepth 6 -path "*themes/wallpapers*" | head
```
Runtime proof after `switch` (user-run or approved): wallpaper displays + `modules/scripts/launcher.nix` selection flow works; follow `references/hyprland-lua-runtime-verify.md` if any hyprland lua touched.

---

## Task 5 — Overlay / pkgs staleness audit

Read-only first:
1. `grep -rn "ananicy" ~/NixOS --include="*.nix"` → is `overlays/patches/ananicy-cpp-cstring.patch` referenced anywhere? Orphaned → propose `git rm` (skill: orphaned patches stay only if user blocks rm).
2. For each `pkgs/` entry (`openai.nix`, `marimo.nix`, `pokego.nix`, `hunspell-km`, `sddm-themes/*`, `typescript-language-server`): confirm referenced from `pkgs/default.nix` AND imported by a module. Unreferenced on both → removal candidate list for user.
3. `vesktop`/`discord` overrides: check against the locked pin (per `references/overlay-stale-on-next-bump.md`): read the package.nix in `nix eval --impure --expr 'let f = builtins.getFlake "/home/archdev/NixOS"; in f.inputs.nixpkgs.outPath'` store path; confirm override args still exist. Stale → remove, don't port.
4. `nix eval` each remaining overlay package version — one eval, all names, per skill's audit pattern.

**User gate:** removal list approved.
**Verification:** real build of `nixwiz` toplevel (Task 4's command) — overlay eval failures surface there.

---

## Task 5.5 — Dependency duplication: closure multi-versioning + profile migration

**What the user observed:** apps running their own `/nix/store/...` copies of binaries instead of the installed ones. Measured: ~15 GB of the 32.5 GiB live closure is the same shared deps built multiple times, PLUS a 9.9 GiB `nix profile` closure pinned to an old registry rev with its own copies of everything.

### 5.5a — Map the owners (read-only)

```bash
# For each multi-version pname, name the app pulling it:
nix why-depends /run/current-system /nix/store/<path>-electron-44.5.1 2>/dev/null
# (already known: signal-desktop→e44.5.1, github-desktop→e43.7.7)
```
Map all: ffmpeg-headless (9), python3 real builds (3.13.12, 3.14.6, 3.14.7), nodejs (24 vs 26), gcc (15). Produce a table: dep-version ← owning app.

### 5.5b — nix profile → flake migration (biggest win, skill recipe exists)

Per the nixos skill's **"Nix Profile to NixOS System Package Migration"** recipe:

1. Create `modules/programs/security/default.nix` (or extend `hosts/nixwiz/host-packages.nix`) with the 46 profile tools from the **flake's** nixpkgs — they then SHARE the system's python/gcc/openssl instead of carrying old private copies.
2. Version-parity check BEFORE migrating (channel rev is old; unstable may have renames/removals): `nix eval` each name against the flake pin (skill's `nixpkgs-bump-migration` reference). Any breakage → per-tool decision (keep on stable via `pkgs.stable`, or leave in profile).
3. hermes `packages.desktop` entry: follow `references/hermes-desktop-nixos.md` for proper integration instead of the profile install.
4. `nix profile list` snapshot → `nix profile remove <entry>` (batch) → rebuild → verify: tools still run (`which` + `--version`), user data in `~/.<tool>/` untouched (never affected by rebuilds).
5. Commit: `feat(pentest): migrate nix profile security suite into flake`.

### 5.5c — Overlay alignment (selective, per-app, TESTED)

Multi-versioning is partly Nix-by-design — do NOT blanket-override. Only align where the win is big and the override survives testing:

| Candidate | Win | Method |
|---|---|---|
| electron 43.7.7 → 44.5.1 | ~2.4 GB | `github-desktop.override { electron = pkgs.electron_44; }` — real build + manual app launch test |
| ffmpeg majors ×9 | up to ~2 GB | identify majors via 5.5a; align apps to the dominant major via overlay |
| python 3.13/3.14.6 → 3.14.7 | ~300 MB | only if the owning app accepts it; per skill: scoped overrides, drvPath check |

Each alignment is an override that **goes stale at the next nixpkgs bump** (skill: overlay-stale-on-next-bump) — remove, don't repair, when upstream catches up.

### 5.5d — After `switch`: GC

Offer (user runs): `sudo nix-collect-garbage -d` — removes old generations + orphaned old-rev paths from the migrated profile. Expect the store to shed a large chunk of the 9.9 GB profile closure + retired dupes. Follow `references/storage-cleanup.md`.

### Verification (5.5)

- Extend `/tmp/tidy-verify.sh` (Task 8): re-measure `nix path-info -Sh /run/current-system` (expect < 32.5 GiB) and re-run the duplicate-count loop (expect electron ≤2, ffmpeg/py/node counts down).
- `nix profile list` → empty (or only user-approved survivors).
- Real build + `nixos-rebuild switch` (user-gated), spot-check 2-3 migrated tools actually launch.
- Every 5.5c override: drvPath changed but app launches (green build ≠ working app — per skill, runtime test required).

---

## Task 6 — flake.nix hygiene

1. Delete the commented-out input block (noctalia, doom-config, nixvim, plasma-manager, zen-browser, neovim) — git history preserves them. **User gate** (some may be "future plans" the user wants visible).
2. No dead live inputs (verified in recon — nothing to remove).
3. `git add flake.nix && git commit flake.nix -m "chore(flake): drop commented-out input block"`.

**Verification:** `nix flake check --no-build 2>/tmp/fc.err; echo EXIT=$?` (pipefail rule if piping) — or skip to Task 7's builds as proof.

---

## Task 7 — Eval warnings pass

Using Task 0's warning list + `references/nixpkgs-warning-fixes.md`:
1. Fix each renamed/deprecated option in the modules it points to (one commit group per module area: `fix(<area>): resolve renamed option X`).
2. Re-run per host:
   ```bash
   for h in <surviving hosts>; do
     nix build .#nixosConfigurations.$h.config.system.build.toplevel --dry-run >/dev/null 2>/tmp/ev2-$h.err
     echo "$h EXIT=$? warnings=$(grep -ci warning /tmp/ev2-$h.err)"
   done
   ```
3. Zero warnings = done; any survivor is documented + user-approved (some are unfixable upstream noise).

---

## Task 8 — Final verification (verification-before-completion skill)

ONE re-runnable script, left in /tmp:

```bash
#!/usr/bin/env bash
# /tmp/tidy-verify.sh
set -o pipefail
cd /home/archdev/NixOS || exit 1
FAIL=0
for h in <surviving hosts>; do
  nix build ".#nixosConfigurations.$h.config.system.build.toplevel" \
    --no-link -o "/tmp/tl-$h" 2>"/tmp/tidy-build-$h.err" \
    && echo "BUILD $h OK" || { echo "BUILD $h FAIL"; FAIL=1; }
  echo "  warnings-$h: $(grep -ci warning "/tmp/tidy-build-$h.err" || true)"
done
echo "git-status-clean: $(test -z "$(git status --porcelain)" && echo yes || echo NO)"
echo "repo-size: $(du -sh . | cut -f1) (baseline: $(grep 'G\s*$' /tmp/tidy-baseline.txt | head -1))"
echo "commits: $(git log --oneline | head -15 | tr '\n' '|')"
exit $FAIL
```

Rules: run fresh, report output **verbatim**, say BLOCKED for anything not executed, never claim success on dry-run alone.

**Switch (user's call):** `sudo nixos-rebuild switch --flake ~/NixOS#nixwiz` — offered, not run unprompted. Then the runtime wallpaper/launcher spot-check from Task 4.

---

## Commit discipline (applies to every task)

- Conventional commits, logical groups, pathspec form, index checked before each commit
- Never `git commit -a`; never `git push` unprompted
- New files: `git add -N` before any eval that must see them
- Leave WIP staged-but-uncommitted where the user hasn't decided (dns.nix)

## Out of scope (explicitly)

- `dev-shells/` (548K, upstream template, self-contained) — candidate for a future pass if user wants
- `secrets/` + `.sops.yaml` — untouched, sensitive
- Any behavior changes to the running desktop (only structure/hygiene)