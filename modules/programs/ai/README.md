# AI Programs Module for NixOS

This directory contains NixOS modules for integrating AI-related programs into your system. Currently, it includes the `pi-agent` module.

## `pi-agent` Module

This module integrates the `pi` coding agent directly from your local `pi-mono` monorepo clone into your NixOS system, making it available system-wide.

### 1. File Location

The `pi-agent.nix` derivation file is located at:

`~/NixOS/modules/programs/ai/pi-agent.nix`

### 2. `pi-mono` Source Path

The derivation relies on your local `pi-mono` repository clone. It expects it at the absolute path:

`/home/scriptwiz/document/code/agent/pi-mono`

**IMPORTANT**: If your `pi-mono` clone is at a different location, you **must** update the `src.path` within `~/NixOS/modules/programs/ai/pi-agent.nix` accordingly.

### 3. Integration into `configuration.nix`

To enable the `pi-agent` module, you need to import it into your main `~/NixOS/configuration.nix` (or `/etc/nixos/configuration.nix`).

Add the following lines to your `configuration.nix`:

```nix
{ config, pkgs, lib, ... }:

let
  # Import your custom modules
  # Make sure the path is correct relative to your configuration.nix
  piAgentModule = import ./modules/programs/ai/pi-agent.nix {
    inherit pkgs lib;
    stdenv = pkgs.stdenv;
    fetchFromPath = pkgs.fetchFromPath;
    nodejs_20 = pkgs.nodejs_20; # Or your preferred Node.js version
    npm = pkgs.npm;
    writeShellScriptBin = pkgs.writeShellScriptBin;
  };
in
{
  # Add the pi-coding-agent to your system's packages
  environment.systemPackages = with pkgs; [
    # ... existing packages
    piAgentModule
  ];

  # ... other NixOS configuration ...
}
```

**Note on `nodejs_20`**: The module explicitly uses `pkgs.nodejs_20`. If you need a different Node.js version, change it in both the `pi-agent.nix` file and the `import` statement in `configuration.nix`.

### 4. Rebuild your NixOS System

After updating your `configuration.nix` to include these changes, rebuild your system:

```bash
sudo nixos-rebuild switch
```

This process will:
*   Provide the necessary Node.js and npm environment within a sandboxed Nix build.
*   Execute `npm install` and `npm run build` using your local `pi-mono` source.
*   Create a `pi` executable wrapper and symlink it into your system's PATH.

### 5. Verify Installation

Once the rebuild is successful, open a new terminal (or re-source your shell) and run `pi`:

```bash
pi --help
```

You should see the help output from the `pi` coding agent, confirming it's installed and executable directly from your NixOS system.

## Important Considerations

*   **Local Source Dependency**: This setup creates a direct dependency on your local `pi-mono` clone. If the source directory is moved or deleted, the Nix build will fail.
*   **Reproducibility**: For production or highly reproducible environments, it's generally recommended to use `fetchFromGitHub` or `fetchGit` with a specific commit hash for `pi-mono` rather than `fetchFromPath`. This ensures the exact source code is used regardless of local changes.
