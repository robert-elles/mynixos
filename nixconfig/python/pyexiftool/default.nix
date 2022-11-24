{ lib, buildPythonPackage, fetchPypi, setuptools, setuptools-scm }:

buildPythonPackage rec {
  pname = "PyExifTool";
  version = "0.5.4";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-0UJE3tPK+w2wHKi9hUU+2ZsNmgvKymujEG/2YrWAyJA=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ setuptools ];
  meta = with lib; {
    description =
      "PyExifTool is a Python library to communicate with an instance of Phil Harvey's ExifTool command-line application.";
    homepage = "https://github.com/sylikc/pyexiftool";
  };
}

