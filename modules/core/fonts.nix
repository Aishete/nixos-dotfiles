{ pkgs, host, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) monospaceFont;
  # Caelusevka: custom Iosevka build vendored byte-identical from
  # git.symlinx.net/daccfiles (dacctal's rice, commit 6917d7c era = v34
  # variant names, matches nixpkgs iosevka 34.7.0). One-time from-source
  # compile (~20-40 min, big-parallel); nix caches it afterwards.
  caelusevka = pkgs.iosevka.override {
    set = "Caelusevka";
    # nixpkgs targets ttf::"Iosevka${set}" but the vendored file declares
    # [buildPlans.Caelusevka*] -> rename the plan prefix so the parent AND
    # all sub-tables (.variants/.weights/.slopes) land under the expected
    # IosevkaCaelusevka name (a partial rename leaves an orphan plan that
    # fails validation with "does not have a family name").
    privateBuildPlan = builtins.replaceStrings
      ["[buildPlans.Caelusevka"]
      ["[buildPlans.IosevkaCaelusevka"]
      (builtins.readFile ./caelusevka-build-plans.toml);
  };
  # Nerd-icon-patched Caelusevka: his glyph shapes + nerd icons (powerline,
  # devicons, weather...) added by nerd-font-patcher. Originals stay
  # pristine; reference as "Caelusevka Nerd Font".
  caelusevkaNerd = pkgs.runCommand "caelusevka-nerd-font"
    {
      nativeBuildInputs = [ pkgs.nerd-font-patcher ];
    } ''
    export HOME=$TMPDIR
    mkdir -p $TMPDIR/patched $out/share/fonts/truetype
    for f in ${caelusevka}/share/fonts/truetype/*.ttf; do
      nerd-font-patcher "$f" --complete --no-progressbars --outputdir $TMPDIR/patched
    done
    install $TMPDIR/patched/*.ttf $out/share/fonts/truetype/
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
