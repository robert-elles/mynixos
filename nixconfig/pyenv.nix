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
in with python-packages;
let
  pypi = name:
    { ... }@pypkgs:
    callPackage (./python + "/${name}") ({
      inherit buildPythonPackage fetchPypi setuptools setuptools-scm;
    } // pypkgs);
  whatlastgenre = pkgs.python3Packages.buildPythonPackage {
    pname = "whatlastgenre";
    version = "0.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "YetAnotherNerd";
      repo = "whatlastgenre";
      rev = "8af22282f925442945acd83de52760de9c78f3c7";
      hash = "sha256-QjAJ5hNbX1+P33PN5d4AY4qldaTj6/WjjVH7vs9mEWE=";
    };
    pyproject = true;
    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = with pkgs.python3Packages; [ mutagen requests ];
    doCheck = false;
  };
  pyexiftool = pypi "pyexiftool" { };
  eventkit = pypi "eventkit" { inherit numpy; };
  hifiscan =
    pypi "hifiscan" { inherit numba pyqtgraph pyqt6 sounddevice eventkit; };
  largestinteriorrectangle = pypi "largestinteriorrectangle" { inherit numba; };
  stitching = pypi "stitching" { inherit numba largestinteriorrectangle; };

  my-python-packages = python-packages:
    with python-packages; [
      requests
      # stitching
      # hifiscan
      # subliminal
      # pyexiftool
      # audiblez
      # piexif
      beautifulsoup4
      jupyter
      pandas
      numpy
      matplotlib
      whatlastgenre
      # autopep8
      # pytest
      # watchdog
      # debugpy
      # subliminal # broken
    ];
  python-with-my-packages = python.withPackages my-python-packages;
in { environment.systemPackages = [ python-with-my-packages ]; }
