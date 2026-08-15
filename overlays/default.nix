{ host, inputs, ... }:
let
  inherit (import ../hosts/${host}/variables.nix) sddmTheme;
in
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
    # ananicy-cpp 1.2.0 fails with the new clang/libc++: std::memset /
    # std::intN_t used without <cstring>/<cstdint> (transitive includes
    # dropped). Patched until nixpkgs carries the upstream fix.
    ananicy-cpp = prev.ananicy-cpp.overrideAttrs (old: {
      patches = (old.patches or []) ++ [ ./patches/ananicy-cpp-cstring.patch ];
    });
    # wf-recorder 0.6.0 uses AVCodec.sample_fmts, removed in ffmpeg 7+;
    # build against ffmpeg_6 until upstream ships a compatible release.
    wf-recorder = prev.wf-recorder.override {
      ffmpeg = prev.ffmpeg_6;
    };
  };
}
