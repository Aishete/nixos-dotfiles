{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "geared-cursor";
  version = "1.0.0";

  src = ./geared-steel-64x;

  installPhase = ''
    mkdir -p $out/share/icons/Geared-Steel-64x
    cp -r $src/* $out/share/icons/Geared-Steel-64x/
  '';

  meta = {
    description = "Geared Steel 64x animated cursor — pre-rendered 3D cursor for Linux";
    homepage = "https://github.com/piraker-grinor/geared-cursor";
    license = pkgs.lib.licenses.unfree;
    platforms = pkgs.lib.platforms.linux;
  };
}
