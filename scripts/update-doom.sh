#!/usr/bin/env bash
# Update doom-config and rebuild
set -euo pipefail
cd "$(dirname "$0")/.."
nix flake update doom-config
sudo nixos-rebuild switch --flake .
