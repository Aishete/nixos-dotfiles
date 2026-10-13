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
            # openai 2.53.0: 4/865 tests fail — test_mtls_http_client.py runs
            # repo example scripts with a hardcoded 15s subprocess timeout that
            # expires in the sandbox (slow/loaded machine). Runtime unaffected.
            # mcp (FastMCP) 1.29.0: 1 failed + 5 errors — test servers bind a
            # localhost port and must start within 20s; they time out in the
            # sandbox/under parallel build load. Runtime unaffected.
            # python-lsp-server 1.14.0: 1/204 failed — rope autoimport notebook
            # test raises TimeoutError in sandbox. Runtime unaffected.
            # jupyter-server 2.21.0: pytest-timeout kills a hung kernels
            # test_connection.py (test-only). Runtime unaffected.
            # jupytext 1.19.5: 3/4115 tests fail — sandbox sqlite tmpdir races
            # ("database is locked" / "readonly database"). Runtime unaffected.
            jupytext = noPytest pyprev.jupytext;
            jupyter-server = noPytest pyprev.jupyter-server;
            python-lsp-server = noPytest pyprev.python-lsp-server;
            mcp = noPytest pyprev.mcp;
            openai = noPytest pyprev.openai;
            httpx2 = noPytest pyprev.httpx2;
          })
      ];
  };
}
