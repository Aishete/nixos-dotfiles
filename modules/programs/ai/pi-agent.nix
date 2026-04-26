{ lib, stdenv, fetchFromPath, nodejs_20, npm, writeShellScriptBin, ... }:

stdenv.mkDerivation rec {
  pname = "pi-coding-agent";
  version = "0.0.1"; # You might want to derive this from package.json or use a fixed version

  src = fetchFromPath {
    path = /home/scriptwiz/document/code/agent/pi-mono; # <<< IMPORTANT: This path points to your pi-mono clone
  };

  nativeBuildInputs = [ nodejs_20 npm ];

  buildPhase = ''
    echo "Running npm install..."
    # Using --no-audit to avoid network requests for audit reports during build
    npm install --ignore-scripts --no-audit

    echo "Running npm run build..."
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/bin

    CLI_PATH="$src/packages/coding-agent/dist/cli.js"
    if [ ! -f "$CLI_PATH" ]; then
      echo "Error: Could not find built CLI at $CLI_PATH"
      find "$src/packages/coding-agent/dist"
      exit 1
    fi

    ${writeShellScriptBin "pi" ''
      export PATH="${nodejs_20}/bin:$PATH"
      exec node "$CLI_PATH" "$@"
    ''}
  '';

  dontPatchShebangs = true; # Necessary as npm might create scripts with shebangs
}
