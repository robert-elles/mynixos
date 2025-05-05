{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, wxpython
, espeak
, ffmpeg
, poetry-core
, beautifulsoup4
, ebooklib
, kokoro
, misaki
, pick
, soundfile
, spacy
, tabulate
}:

buildPythonPackage rec {
  pname = "audiblez";
  version = "0.4.9";
  doCheck = false;
  format = "pyproject";
  # format = "wheel";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yOBU/83CJgaQj4drbC+ch78Hv3GRZo9F1W340lZZy2U=";
  };
  nativeBuildInputs = [ setuptools-scm poetry-core ];
  propagatedBuildInputs = [
    setuptools
    wxpython
    espeak
    ffmpeg
    beautifulsoup4
    ebooklib
    kokoro
    misaki
    pick
    soundfile
    spacy
    tabulate
  ];
  meta = {
    description = "Generate audiobooks from e-books";
    homepage = "https://github.com/santinic/audiblez";
  };
}
