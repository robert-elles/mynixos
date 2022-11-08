{ lib, buildPythonPackage, fetchPypi, setuptools, setuptools-scm, numpy }:

buildPythonPackage rec {
  pname = "eventkit";
  version = "1.0.0";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ycS7ipaF5BMehFiCUSpjDWpXrO4UjzivKGVip2hz5Kk=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ setuptools numpy ];
  meta = with lib; {
    description = "Event-driven data pipelines";
    homepage = "https://github.com/erdewit/eventkit";
  };
}
