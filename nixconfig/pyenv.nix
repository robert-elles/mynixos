{ pkgs, ... }:
with pkgs;
with python311.pkgs;
let
  py = python311;

  pypi = name:
    { ... }@pypkgs:
    callPackage (./python + "/${name}") ({
      inherit buildPythonPackage fetchPypi setuptools setuptools-scm;
    } // pypkgs);

  pyexiftool = pypi "pyexiftool" { };
  eventkit = pypi "eventkit" { inherit numpy; };
  hifiscan =
    pypi "hifiscan" { inherit numba pyqtgraph pyqt6 sounddevice eventkit; };
  largestinteriorrectangle = pypi "largestinteriorrectangle" { inherit numba; };
  stitching = pypi "stitching" { inherit numba largestinteriorrectangle; };

  my-python-packages = python-packages:
    with python-packages; [
      requests
      stitching
      hifiscan
      # subliminal
      pyexiftool
      piexif
      beautifulsoup4
      jupyter
      pandas
      numpy
      matplotlib
      autopep8
      pytest
      watchdog
      debugpy
    ];
  python-with-my-packages = py.withPackages my-python-packages;
in
{
  environment.systemPackages = [
    python-with-my-packages
  ];
}
