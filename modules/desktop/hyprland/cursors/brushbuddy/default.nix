{
  lib,
  stdenv,
  python3,
  imagemagick,
  xcursorgen,
}: let
  srcDir = ./.;
in
  stdenv.mkDerivation {
    pname = "brushbuddy-cursor";
    version = "1.0.0";

    src = srcDir;

    nativeBuildInputs = [python3 imagemagick xcursorgen];

    # build-theme.sh writes $out/cursors + $out/index.theme
    buildPhase = ''
      bash build-theme.sh
    '';

    installPhase = ''
      mkdir -p $out/share/icons/Brushbuddy
      mv $out/cursors $out/share/icons/Brushbuddy/cursors
      mv $out/index.theme $out/share/icons/Brushbuddy/index.theme
    '';

    meta = {
      description = "Animated Brushbuddy cursor theme converted from ANI pack";
      platforms = lib.platforms.linux;
    };
  }
