{ pkgs, ... }:
with pkgs;
let
  python = pkgs.python3.override {
    self = python;
    packageOverrides = pyfinal: pyprev: {
      kokoro = pyfinal.callPackage ./python/kokoro/default.nix { };
      misaki = pyfinal.callPackage ./python/misaki/default.nix { };
      audiblez = pyfinal.callPackage ./python/audiblez/default.nix { };
    };
  };
  python-packages = python3.pkgs;
in
with python-packages;
let
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
      # audiblez
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
      # subliminal # broken
    ];
  python-with-my-packages = python.withPackages my-python-packages;
in
{
  environment.systemPackages = [
    python-with-my-packages
  ];
}
