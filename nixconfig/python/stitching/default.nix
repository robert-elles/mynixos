{ lib
, buildPythonPackage
, fetchPypi
, largestinteriorrectangle
, setuptools
, setuptools-scm
, opencv4
, numba
}:

buildPythonPackage rec {
  pname = "stitching";
  version = "0.3.0";
  doCheck = false;
  format = "pyproject";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-dSrXWfbHYdGs6WTPeJ3xv4kl3fKGguAvPBFzfumw0Ko=";
  };
  postPatch = ''
    sed -ie '/opencv-python/d' setup.cfg
  '';
  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ setuptools numba opencv4 largestinteriorrectangle ];
  meta = {
    description = "A Python package for fast and robust Image Stitching";
    homepage = "https://github.com/lukasalexanderweber/stitching";
  };
}
