{inputs, pkgs, ...}: {
  # Delta (zed-industries, delta.dev) — proprietary agent binary, distributed
  # via zed's official flake. Wrapped with Nix runtime paths + updater
  # disabled by the flake; desktop entry uses `delta open %U` for deep links.
  # nixpkgs.follows keeps Delta's base aligned with the system pin, so its
  # glibc never fights the system's Mesa/LLVM (README's #1 NixOS pitfall).
  environment.systemPackages = [
    inputs.delta.packages."${pkgs.stdenv.hostPlatform.system}".delta
  ];
}