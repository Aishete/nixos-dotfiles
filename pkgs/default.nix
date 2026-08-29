{ host, pkgs, ... }:
{
  # these will be overlayed in nixpkgs automatically.
  # for example: environment.systemPackages = with pkgs; [pokego];
  pokego = pkgs.callPackage ./pokego.nix { };

  # marimo 0.24.0 + recommended extras (SQL engine, AI assistant, sandbox) —
  # shadows the nixpkgs package (0.23.16, base deps only). See marimo.nix.
  # Called in python3Packages scope (buildPythonPackage lives there), then
  # wrapped with toPythonApplication for the `marimo` CLI — same shape as
  # nixpkgs' own `marimo = with python3Packages; toPythonApplication marimo;`.
  # The python3Packages set is overridden so `openai` = 2.46.0 (see
  # openai.nix) — pydantic-ai-slim 2.31.1 needs openai >= 2.45.0 for the
  # prompt_cache_options kwarg; the pin's 2.41.1 breaks marimo AI.
  marimo = let
    py = pkgs.python3Packages.override {
      overrides = _: _prev: {
        openai = pkgs.python3Packages.callPackage ./openai.nix { };
      };
    };
  in
    py.toPythonApplication (py.callPackage ./marimo.nix { });
}
