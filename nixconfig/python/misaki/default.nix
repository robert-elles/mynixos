{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "misaki";
  version = "0.9.4";
  doCheck = false;
  format = "pyproject";
  # format = "wheel";
  src = fetchPypi {
    inherit pname version;
    # sha256 = "sha256-yOBU/83CJgaQj4drbC+ch78Hv3GRZo9F1W340lZZy2U=";
    sha256 = lib.fakeSha256;
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [
    setuptools
  ];
  meta = {
    description = "An inference library for Kokoro-82M";
    homepage = "https://github.com/hexgrad/kokoro";
  };
}
