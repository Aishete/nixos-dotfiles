{ host, inputs, ... }:
{
  # Overlay custom derivations into nixpkgs so you can use pkgs.<name>
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit host;
    };

  # https://wiki.nixos.org/wiki/Overlays
  modifications = final: prev: {
    nur = inputs.nur.overlays.default;
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
    vesktop = prev.vesktop.override {
      withSystemVencord = false;
      withMiddleClickScroll = true;
    };
    discord = prev.discord.override {
      withVencord = true;
      withOpenASAR = true;
      enableAutoscroll = true;
    };
    # 2026-10-16: REMOVED the global pythonPackagesExtensions block (9
    # noPytest/noCheck overrides added across 2026-10-15/16). Rationale: a
    # global extension changes EVERY python package's drv hash in EVERY set,
    # so hydra-published prebuilt outputs stop substituting — every python
    # package in the system built from source (the multi-day "build swamp").
    # If a later pin introduces real test failures, scope the override
    # instead: pkgs/default.nix's marimo set override, or a narrow
    # python3Packages.override { overrides = [...]; } limited to the exact
    # packages — never a global extension.
  };
}
