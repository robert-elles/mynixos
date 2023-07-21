{ pkgs ? import <nixpkgs> { } }:
let
  python = pkgs.python3;
  pythonPackages = python.pkgs;
in
pythonPackages.buildPythonApplication rec {
  pname = "gramps-webapi";
  version = "1.1.5";

  # format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps-webapi";
    rev = "v${version}";
    sha256 = "sha256-KLRhN9s5Qbe2I13Ysb05jF7Mh2Ya1eU0vh7Ew3ZjoTU=";
  };

  # nativeBuildInputs = with python.pkgs; [
  # ];

  propagatedBuildInputs = with python.pkgs; [
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
    pyicu
    ffmpeg-python
    sqlalchemy
    pdf2image
    redis
    gunicorn
  ];

  doCheck = false;

  passthru = {
    inherit python;
    # pythonPath = [
    #   # Add the path to the gramps-webapi module
    #   # "$out/gramps_webapi"
    # ] ++ pythonPackages.buildPythonPath propagatedBuildInputs;
    pythonPath = pythonPackages.makePythonPath propagatedBuildInputs;
  };

  installPhase = ''
    # mkdir -p $out/gramps_webapi
    cp -dr --no-preserve='ownership' . $out
  '';

  meta = {
    description = "A RESTful web API for Gramps";
    homepage = "https://github.com/gramps-project/gramps-webapi/";
    # license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ robert ];
    # platforms = platforms.all;
  };
}
