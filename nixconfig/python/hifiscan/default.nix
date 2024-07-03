{ buildPythonPackage
, fetchPypi
, setuptools
, setuptools-scm
, numba
, pyqtgraph
, pyqt6
, sounddevice
, eventkit
}:

buildPythonPackage rec {
  pname = "hifiscan";
  version = "1.5.2";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-8eystqjNdDP2X9beogRcsa+Wqu50uMHZv59jdc5GjUc=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs =
    [ setuptools numba pyqtgraph pyqt6 sounddevice eventkit ];
  meta = {
    description = "Optimize the audio quality of your loudspeakers";
    homepage = "https://github.com/erdewit/HiFiScan";
  };
}
