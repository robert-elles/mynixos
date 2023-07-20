{ config, pkgs, lib, mach-nix, ... }:
with pkgs;
with python310.pkgs;
let

  # poetry_py_env = pkgs.poetry2nix.mkPoetryEnv { projectDir = ./poetry; };

  # mach_nix_py_env = mach-nix.lib."x86_64-linux".mkPython {
  #   python = "python310";
  #   ignoreDataOutdated = true;
  #   requirements = ''
  #     requests
  #     beautifulsoup4
  #     jupyter
  #     pandas
  #     numpy
  #     matplotlib
  #   '';
  #   #    requirements = lib.concatStringsSep "\n" [ "ebooklib" "jupyter" ];
  #   #    _.tomli.propagatedBuildInputs.mod = pySelf: self: oldVal:
  #   #      oldVal ++ [ pySelf.flit-core ];
  # };

  # pypi_drv = { pname, version, sha256 ? lib.fakeSha256, nbi ? [ ], pbi ? [ ] }:
  #   callPackage buildPythonPackage rec {
  #     inherit pname version;
  #     doCheck = false;
  #     format = "pyproject";
  #     src = fetchPypi { inherit pname version sha256; };
  #     nativeBuildInputs = [ setuptools-scm ] ++ nbi;
  #     propagatedBuildInputs = [ setuptools ] ++ pbi;
  #   };

  # ebooklib = pypi_drv {
  #   pname = "EbookLib";
  #   version = "0.18";
  #   sha256 = "sha256-OFYmQ6e8lNm/VumTC0kn5Ok7XR0JF/aXpkVNtaHBpTM=";
  #   pbi = [ six lxml ];
  # };

  # pykson = pypi_drv {
  #   pname = "pykson";
  #   version = "0.9.9.8.14";
  #   sha256 = "sha256-6jL7js+Px4WMPbOObRwKpSe7jG7Lxa1v+DCk6OE0SyM=";
  #   pbi = [ jdatetime six pytz python-dateutil ];
  # };

  pypi = name:
    { ... }@pypkgs:
    callPackage (./python + "/${name}") ({
      inherit buildPythonPackage fetchPypi setuptools setuptools-scm;
    } // pypkgs);

  #  ebooklib = pypi "ebooklib" { inherit six lxml; };
  pyexiftool = pypi "pyexiftool" { };
  eventkit = pypi "eventkit" { inherit numpy; };
  hifiscan =
    pypi "hifiscan" { inherit numba pyqtgraph pyqt6 sounddevice eventkit; };
  largestinteriorrectangle = pypi "largestinteriorrectangle" { inherit numba; };
  stitching = pypi "stitching" { inherit numba largestinteriorrectangle; };

  #  my-mach-nix-packages = ps:
  #    with ps;
  #    [
  #      (mach-nix.lib."x86_64-linux".mkPythonShell {
  #        requirements = ''
  #          requests
  #          ebooklib
  #        '';
  #      })
  #    ];

  my-python-packages = python-packages:
    with python-packages; [
      requests
      stitching
      hifiscan
      subliminal
      pyexiftool
      piexif
      beautifulsoup4
      jupyter
      pandas
      numpy
      matplotlib
      autopep8
      pytest
      subliminal
    ];
  python-with-my-packages = python3.withPackages my-python-packages;
  #  python-with-my-packages = python3.withPackages my-mach-nix-packages;
in
{

  environment.systemPackages = [
    python-with-my-packages
    #    poetry_py_env
    #    mach_nix_py_env
  ];
}
