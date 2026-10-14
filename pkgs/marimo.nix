# marimo 0.24.0 with optional features (SQL engine + AI/recommended extras).
# Overrides the nixpkgs package (0.23.16, base deps only) via the flake's
# pkgs/default.nix overlay — see `marimo` in modules/programs/misc/app/default.nix.
#
# The nixpkgs marimo package builds only the base dependencies. marimo's
# "recommended" extras unlock:
#   - SQL cells: duckdb, polars[pyarrow], sqlglot
#   - Built-in AI assistant: pydantic-ai-slim[openai], altair, nbformat,
#     cryptography, ruff
#   - Sandbox execution: uv, pyzmq
# Base deps come from the nixpkgs derivation (click, starlette, uvicorn,
# pyzmq, msgspec, narwhals, ...) — we keep them all, bump the version, and
# add the extras on top.
{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  uv-build,
  # base dependencies (mirror nixpkgs package)
  click,
  docutils,
  itsdangerous,
  jedi,
  loro,
  markdown,
  msgspec,
  narwhals,
  packaging,
  psutil,
  pygments,
  pymdown-extensions,
  python-multipart,
  pyyaml,
  pyzmq,
  starlette,
  tomlkit,
  uvicorn,
  websockets,
  # extra: AI assistant / recommended
  pydantic-ai-slim,
  openai,
  altair,
  nbformat,
  cryptography,
  ruff,
  # extra: sandbox
  uv,
  # MCP server connections
  mcp,
  # tests
  versionCheckHook, # (kept) — sqlframe/pytest-postgresql/narwhals-env failures were all in the removed-extras chain
  # for wrapProgram (PYTHONPATH injection into the CLI wrapper)
  makeWrapper,
  python,
}:
buildPythonPackage rec {
  pname = "marimo";
  version = "0.24.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    # sha256 of the FULL sdist (39 MB). Warning: a truncated download produced
    # a plausible-looking but WRONG hash (a9341a12...) — always hash the
    # complete artifact (`nix hash file <full-tar.gz> --sri`).
    hash = "sha256-MKrq5aWTbfUkgU/d2Y9LJg0waPl98mEdJS/kslPz+4A=";
  };

  build-system = [ uv-build ];

  nativeBuildInputs = [ makeWrapper ];

  pythonRelaxDeps = [
    # nixpkgs has jedi 0.20.0; marimo pins <0.20.0
    "jedi"
  ];

  dependencies = [
    click
    docutils
    itsdangerous
    jedi
    loro
    markdown
    msgspec
    narwhals
    packaging
    psutil
    pygments
    pymdown-extensions
    python-multipart
    pyyaml
    pyzmq
    starlette
    tomlkit
    uvicorn
    websockets
    # --- marimo[recommended] extras (trimmed 2026-10-16, user-approved):
    # dropped SQL cells (duckdb/polars/pyarrow/sqlglot), vegafusion/vl-convert
    # charts, and python-lsp-server — each drags monster builds (arrow-cpp,
    # duckdb/polars/vegafusion Rust compiles, pylsp closure) and broken test
    # chains on the locked pin. Re-add individually via marimo[<extra>] if
    # ever needed. AI assistant + sandbox (uv) + MCP kept.
    # --- AI assistant
    pydantic-ai-slim
    openai # pydantic-ai-slim[openai]
    altair
    nbformat
    cryptography
    ruff
    # sandbox execution
    uv
    # MCP server connections
    mcp
  ];

  pythonImportsCheck = [ "marimo" ];

  # The marimo KERNEL subprocess only gets marimo/zmq/msgspec on PYTHONPATH
  # (marimo/_session/_venv.py get_kernel_pythonpath) — so marimo tries to
  # `pip install` missing deps against the immutable Nix store python ->
  # PEP 668 "externally-managed-environment".
  # Fix: inject the FULL closure site-packages into PYTHONPATH on the CLI
  # wrapper. The kernel subprocess inherits os.environ (construct_kernel_env
  # prepends its own entries to the existing PYTHONPATH), so the kernel sees
  # every dependency.
  # (.pth files in PYTHONPATH dirs do NOT work — CPython 3.14 doesn't
  # process them there; tested before choosing this approach.)
  postInstall = ''
    wrapProgram $out/bin/marimo \
      --prefix PYTHONPATH : ${lib.concatStringsSep ":" (map (p: "${p}/lib/${python.libPrefix}/site-packages") dependencies)}
  '';

  # The pypi archive does not contain tests so we do not use pytestCheckHook
  nativeCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Reactive Python notebook that's reproducible, git-friendly, and deployable as scripts or apps (0.24.0 + recommended extras)";
    homepage = "https://github.com/marimo-team/marimo";
    changelog = "https://github.com/marimo-team/marimo/releases/tag/${version}";
    license = lib.licenses.asl20;
    mainProgram = "marimo";
    maintainers = with lib.maintainers; [ akshayka dmadisetti ];
  };
}
