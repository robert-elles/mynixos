{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, poetry-core
, torch
, transformers
, loguru
, numpy
, huggingface-hub
, misaki
}:

buildPythonPackage rec {
  pname = "kokoro";
  version = "0.9.4";
  doCheck = false;
  format = "pyproject";
  # format = "wheel";
  src = fetchPypi {
    inherit pname version;
    # sha256 = "sha256-yOBU/83CJgaQj4drbC+ch78Hv3GRZo9F1W340lZZy2U=";
    sha256 = lib.fakeSha256;
  };
  nativeBuildInputs = [ setuptools-scm poetry-core ];
  propagatedBuildInputs = [
    setuptools
    loguru
    misaki
    numpy
    torch
    transformers
    huggingface-hub
  ];
  meta = {
    description = "An inference library for Kokoro-82M";
    homepage = "https://github.com/hexgrad/kokoro";
  };
}
