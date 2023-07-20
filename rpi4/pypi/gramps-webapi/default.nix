{ pkgs ? import <nixpkgs> { } }:
let
  python = pkgs.python3;
  pypkgs = python.pkgs;
in
pypkgs.buildPythonPackage rec {
  pname = "gramps-webapi";
  version = "1.1.4";
  doCheck = false;
  format = "pyproject";
  src = pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-xRkPdrzVThqXsO1I/NPw/E2uzi8yVm8XU3nRMhDjpPc=";
  };
  # postPatch = ''
  #   sed -ie '/opencv-python/d' setup.cfg
  # '';
  nativeBuildInputs = with pypkgs;[ setuptools setuptools-scm ];
  # propagatedBuildInputs = [ setuptools numba opencv4 largestinteriorrectangle ];

  propagatedBuildInputs = with pypkgs; [
    flask
    flask-compress
    flask-limiter
    flask-cors
    flask-caching
    flask-sqlalchemy
    flask-jwt-extended
    pillow
    bleach
    tinycss2
    whoosh
    jsonschema
    marshmallow
    celery
    click
    boto3
    alembic
    unidecode
    webargs
    ffmpeg-python
    sqlalchemy
    pdf2image
    redis
    gunicorn
  ];

  passthru = {
    inherit python;
    # pythonPath = [
    #   # Add the path to the gramps-webapi module
    #   # "$out/gramps_webapi"
    # ] ++ pythonPackages.buildPythonPath propagatedBuildInputs;
    pythonPath = pypkgs.buildPythonPath propagatedBuildInputs;
  };

  meta = {
    description = "A RESTful web API for the Gramps genealogical database.";
    homepage = "https://github.com/gramps-project/gramps-webapi";
  };
}
