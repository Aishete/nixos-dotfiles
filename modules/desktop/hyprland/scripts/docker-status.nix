{ pkgs, ... }:
pkgs.writeShellScriptBin "docker-status" ''
  # Docker status indicator for waybar
  # Shows running container count

  if ! command -v docker &>/dev/null; then
    printf '{"text":"󰡨","tooltip":"Docker not installed","class":"inactive"}'
    exit 0
  fi

  running=$(docker ps -q 2>/dev/null | wc -l)
  total=$(docker ps -a -q 2>/dev/null | wc -l)

  if [ "$running" -gt 0 ]; then
    # Build tooltip with running container names
    tooltip=$(docker ps --format '{{.Names}} ({{.Status}})' 2>/dev/null | tr '\n' '\n' | sed '$ s/$//')
    printf '{"text":"󰡨 %s","tooltip":"Running: %s\nTotal: %s","class":"active"}' "$running" "$tooltip" "$total"
  elif [ "$total" -gt 0 ]; then
    printf '{"text":"󰡨 0","tooltip":"No running containers\nTotal: %s stopped","class":"stopped"}' "$total"
  else
    printf '{"text":"󰡨","tooltip":"No containers","class":"inactive"}'
  fi
''
