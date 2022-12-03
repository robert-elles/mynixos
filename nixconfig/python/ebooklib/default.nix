{ lib, buildPythonPackage, fetchPypi, setuptools, setuptools-scm, six, lxml }:

buildPythonPackage rec {
  pname = "EbookLib";
  version = "0.18";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-OFYmQ6e8lNm/VumTC0kn5Ok7XR0JF/aXpkVNtaHBpTM=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ setuptools six lxml ];
  meta = with lib; {
    description =
      "Python E-book library for handling books in EPUB2/EPUB3 format -";
    homepage = "https://github.com/aerkalov/ebooklib";
  };
}
