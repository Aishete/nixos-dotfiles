#!/usr/bin/env bash
# Tidy-up final verification — re-runnable. 2026-10-16.
set -o pipefail
cd /home/archdev/NixOS || exit 1
FAIL=0
echo "=== 1. toplevel build (real, not dry-run) ==="
nix build .#nixosConfigurations.nixwiz.config.system.build.toplevel --no-link -o /tmp/tidy-work/tl-profile 2>/tmp/tidy-work/verify-build.err && echo "BUILD nixwiz OK" || { echo "BUILD nixwiz FAIL"; FAIL=1; }
echo "  warnings: $(grep -ci warning /tmp/tidy-work/verify-build.err || true)"
echo "=== 2. closure stats vs baseline (baseline: 32.5 GiB closure, electron x4, python3 x12, nodejs x8, ffmpeg x9) ==="
nix path-info -Sh /tmp/tidy-work/tl-profile 2>/dev/null | tail -1 | awk '{print "  closure: "$1}'
C=$(nix path-info -rSh /tmp/tidy-work/tl-profile 2>/dev/null)
for p in electron python3-3 nodejs ffmpeg-headless; do
  echo "  $p copies: $(echo "$C" | grep -cE "/[0-9a-z]{32}-$p")"
done
echo "=== 3. git state ==="
echo "  status: $(git status --porcelain | wc -l) dirty paths (expect: dns.nix + .github copy/ + docs/)"
git log --oneline | head -3 | sed 's/^/  /'
echo "=== 4. profile state (47 entries at start; 1 = hermes desktop only) ==="
nix profile list 2>/dev/null | sed 's/\x1B\[[0-9;]*m//g' | grep -c "^Name:"
echo "=== 5. repo size (baseline 1.7G) ==="
du -sh . | cut -f1
echo "=== 6. switch candidate ==="
echo "  sudo nixos-rebuild switch --flake ~/NixOS#nixwiz"
exit $FAIL
