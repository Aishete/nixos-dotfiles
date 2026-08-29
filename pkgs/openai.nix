# openai 2.46.0 — override for the pin's 2.41.1.
#
# WHY: pydantic-ai-slim 2.31.1 (marimo's AI layer) calls
# `AsyncCompletions.create(prompt_cache_options=...)` — that kwarg only
# exists in openai >= 2.45.0. The pin's 2.41.1 only knows the older
# `prompt_cache_retention`, so marimo AI fails with:
#   AsyncCompletions.create() got an unexpected keyword argument
#   'prompt_cache_options'. Did you mean 'prompt_cache_retention'?
# No pydantic-ai-slim release works with openai 2.41.1 (2.18.0 already
# requires >=2.45.0), so the openai side must move.
#
# 2.46.0 chosen: first >=2.45 release whose jiter constraint (>=0.10.0)
# is satisfied by the pin's jiter 0.12.0. Same build shape as the
# nixpkgs-unstable package (hatchling, postPatch to relax the pinned
# hatchling==1.26.3).
{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  hatch-fancy-pypi-readme,
  # dependencies
  anyio,
  distro,
  httpx,
  jiter,
  pydantic,
  sniffio,
  tqdm,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "openai";
  version = "2.46.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    # sha256 of the COMPLETE sdist (1.1 MB) — verified with tar -tzf
    hash = "sha256-BCHgc1rEFFHK2JSvTN3wQ1v7+MvFOKwOFbPAYvLdwGo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "hatchling==1.26.3" "hatchling"
  '';

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    anyio
    distro
    httpx
    jiter
    pydantic
    sniffio
    tqdm
    typing-extensions
  ];

  pythonImportsCheck = [ "openai" ];

  meta = {
    description = "Python client library for the OpenAI API (2.46.0 override for marimo/pydantic-ai compatibility)";
    homepage = "https://github.com/openai/openai-python";
    changelog = "https://github.com/openai/openai-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
  };
}
