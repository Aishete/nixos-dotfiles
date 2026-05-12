{pkgs, ...}:
pkgs.writeShellScriptBin "workspaces" ''
  EXISTING=$(${pkgs.i3}/bin/i3-msg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | .num')
  FOCUSED=$(${pkgs.i3}/bin/i3-msg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | select(.focused==true).num')
  echo -n " " # Add spacing before first workspace
  for ws in $(echo "$EXISTING" | sort -n); do
    if [ "$ws" -eq "$FOCUSED" ] 2>/dev/null; then
      echo -n "%{F#cba6f7}$ws%{F-} "
    elif echo "$EXISTING" | grep -q "^$ws$"; then
      echo -n "%{F#89b4fa}$ws%{F-} "
    fi
  done
''
