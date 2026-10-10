{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) monospaceFont;

  # Caelusevka: custom Iosevka variant, VENDORED as prebuilt TTFs.
  #
  # History: originally built from source via pkgs.iosevka.override (custom
  # build plans in ./caelusevka-build-plans.toml, vendored byte-identical
  # from git.symlinx.net/daccfiles @6917d7c, nixpkgs iosevka 34.7.0 era).
  # A from-source Iosevka build takes ~20-40 min and custom build plans
  # NEVER hit the binary cache -> every nixpkgs bump recompiled it (its
  # toolchain inputs churn). As of 2026-10-14 the built TTFs are vendored
  # below instead: package installs are plain file copies, zero compiles.
  #
  # To REGENERATE after editing ./caelusevka-build-plans.toml: re-enable the
  # block below, rebuild once (compiles), then re-copy the new TTFs from the
  # store path into ./fonts/caelusevka*/ and re-vendor (git add + rebuild).
  #
  #   caelusevka = pkgs.iosevka.override {
  #     set = "Caelusevka";
  #     # nixpkgs targets ttf::"Iosevka${set}" but the vendored file declares
  #     # [buildPlans.Caelusevka*] -> rename the plan prefix so the parent AND
  #     # all sub-tables (.variants/.weights/.slopes) land under the expected
  #     # IosevkaCaelusevka name (a partial rename leaves an orphan plan that
  #     # fails validation with "does not have a family name").
  #     privateBuildPlan = builtins.replaceStrings
  #       ["[buildPlans.Caelusevka"]
  #       ["[buildPlans.IosevkaCaelusevka"]
  #       (builtins.readFile ./caelusevka-build-plans.toml);
  #   };
  #   caelusevkaNerd = pkgs.runCommand "caelusevka-nerd-font" {
  #     nativeBuildInputs = [ pkgs.nerd-font-patcher ];
  #   } ''
  #     export HOME=$TMPDIR
  #     mkdir -p $TMPDIR/patched $out/share/fonts/truetype
  #     for f in ${caelusevka}/share/fonts/truetype/*.ttf; do
  #       nerd-font-patcher "$f" --complete --no-progressbars --outputdir $TMPDIR/patched
  #     done
  #     install $TMPDIR/patched/*.ttf $out/share/fonts/truetype/
  #   '';

  caelusevka = pkgs.runCommand "iosevka-caelusevka-vendored" { } ''
    mkdir -p $out/share/fonts/truetype
    cp ${./fonts/caelusevka}/*.ttf $out/share/fonts/truetype/
  '';

  # Nerd-icon-patched Caelusevka (his glyph shapes + nerd icons). TTFs
  # patched once with nerd-font-patcher and vendored; family stays
  # "Caelusevka Nerd Font". Nothing in the flake references it today (kept
  # for parity with the previous build; drop it here if unwanted).
  caelusevkaNerd = pkgs.runCommand "caelusevka-nerd-font-vendored" { } ''
    mkdir -p $out/share/fonts/truetype
    cp ${./fonts/caelusevka-nerd}/*.ttf $out/share/fonts/truetype/
  '';
in
{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      # Nerd Fonts
      maple-mono.NF
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.iosevka
      caelusevka
      caelusevkaNerd

      # Normal Fonts
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [
          "Iosevka Nerd Font"
          monospaceFont
          "Maple Mono NF"
          "Noto Mono"
          "DejaVu Sans Mono" # Default
        ];
        sansSerif = [
          "Noto Sans"
          "DejaVu Sans" # Default
        ];
        serif = [
          "Noto Serif"
          "DejaVu Serif" # Default
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Also configure home-manager fontconfig so apps pick up the defaults
  home-manager.sharedModules = [
    {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            "Iosevka Nerd Font"
            monospaceFont
            "Maple Mono NF"
            "Noto Mono"
            "DejaVu Sans Mono"
          ];
          sansSerif = [
            "Noto Sans"
            "DejaVu Sans"
          ];
          serif = [
            "Noto Serif"
            "DejaVu Serif"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    }
  ];
}