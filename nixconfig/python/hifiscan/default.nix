{ lib
, buildPythonPackage
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
  version = "1.0.1";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-W6agoS8Av+AjzkATwajyEU4PxIqAhk2OyKvNbSmr2Yk=";
  };
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs =
    [ setuptools numba pyqtgraph pyqt6 sounddevice eventkit ];
  meta = {
    description = "Optimize the audio quality of your loudspeakers";
    homepage = "https://github.com/erdewit/HiFiScan";
  };
}
