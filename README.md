# NixOS — nixwiz

Personal NixOS flake for an AMD ThinkPad T495 ("nixwiz"), running Hyprland on Wayland.

Fork lineage: built from the [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS) template (via Aishete's hyprlang fork), heavily restructured.

## What's in the box

| Path | What it is |
|---|---|
| `flake.nix` | Single flake input; one host wired: `nixwiz` |
| `hosts/nixwiz/` | Host config: `configuration.nix`, `hardware-configuration.nix`, `host-packages.nix` (dev tooling), `variables.nix` (user/theme knobs) |
| `modules/core/` | Base system: fonts (vendored Caelusevka Iosevka), dns/adguard, packages, scripts |
| `modules/desktop/` | Hyprland (lua config + rices + waybar/quickshell), i3, gnome, plasma6 leftovers |
| `modules/programs/` | Per-app modules: agent (pi, hermes, delta), browser (firefox + sidebery/caelus chrome), editor, terminal, media, misc |
| `modules/programs/security/` | Pentest tool suite (migrated from `nix profile` into the flake) |
| `modules/themes/` | Catppuccin/Dracula/rose-pine/TokyoNight defaults + the 2 referenced wallpapers |
| `overlays/` | nixpkgs overlays: nur, stable-channel import, vesktop/discord tweaks |
| `pkgs/` | Custom derivations: marimo (base + AI extras), typescript-language-server vendored fix |
| `dev-shells/` | ~40 devenv-style language shells |
| `secrets/` | sops-nix managed |
| `docs/` | Plans + reports (e.g. `docs/plans/2026-10-15-config-tidy-up.md`, `docs/tidy-verify.sh` repo gate) |

## Wallpapers

The browseable library lives **outside the repo** at `~/Pictures/wallpapers/`
(270 files). The rofi picker (`SUPER+SHIFT+W`) and thumbnail cache read it at
runtime and fall back to the 2 in-repo defaults (`modules/themes/wallpapers/`)
if the directory is empty.

## Rebuild

```bash
sudo nixos-rebuild switch --flake ~/NixOS#nixwiz
```

Repo health gate (build + closure stats + git + profile):

```bash
~/NixOS/docs/tidy-verify.sh
```

## Install (fresh machine)

```bash
bash install.sh       # menus are generated from hosts/ automatically
# or bootstrap from a live ISO: bash live-install.sh
```

## Credits

- Base template: [Sly-Harvey/NixOS](https://github.com/Sly-Harvey/NixOS)
- Hyprland lua migration + rice porting patterns: Aishete (hyprlang) fork
- Caelus theming + Sidebery sidebar CSS: [daccfiles](https://git.symlinx.net/daccfiles) (accent swapped to caelus red #f16e65)
- Fonts: Caelusevka (vendored TTFs; regeneration notes in `modules/core/fonts.nix`)