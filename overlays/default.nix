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
    # Python test phases fail here (sandbox flakiness: TLS "server_hostname can
    # only be specified in client mode" against the anyio test's remote server,
    # thread-count races, tmpdir races) and the locked nixpkgs rev has no
    # binary-cache coverage for these python package sets, so they must build
    # locally. Runtime is unaffected; disabling check phases only.
    # TODO: remove at next nixpkgs bump — anyio tests only fail on this pin (stale-on-next-bump rule).
    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (pyfinal: pyprev:
          let
            # pytest via preDistPhases (pytest-hook honors dontUsePytestCheck,
            # NOT doCheck, in current nixpkgs)
            noPytest = p: p.overrideAttrs (_: {dontUsePytestCheck = true;});
            # tests gated by doInstallCheck (e.g. django's own runner)
            noChecks = p:
              p.overrideAttrs (_: {
                doCheck = false;
                doInstallCheck = false;
              });
          in {
            anyio = noPytest pyprev.anyio;
            django = noChecks pyprev.django;
            # httpx2 2.9.1 (pydantic's httpx fork; pulled by openai[httpx2] in the
            # marimo/pydantic-ai chain): 3/1638 tests fail intermittently via
            # pytest 9 PytestUnhandledThreadExceptionWarning (background-thread
            # races in sandbox). Passed 1638/1638 on the previous build run, so
            # runtime is fine — disable the flaky pytest check phase only.
            httpx2 = noPytest pyprev.httpx2;
          })
      ];
  };
}
