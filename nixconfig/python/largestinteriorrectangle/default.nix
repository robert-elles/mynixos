{ lib, buildPythonPackage, fetchPypi, setuptools, setuptools-scm, numba }:

buildPythonPackage rec {
  pname = "largestinteriorrectangle";
  version = "0.1.1";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-giIa9M1Ov56U9IlSAVgnWzlzAawI+ymN8tBoxuXwPb8=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ setuptools numba ];
  meta = {
    description =
      "Largest Interior/Inscribed Rectangle implementation in Python";
    homepage = "https://github.com/lukasalexanderweber/lir";
  };
}

