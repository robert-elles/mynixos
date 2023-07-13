{ pkgs ? import <nixpkgs> { } }:
let
  python = pkgs.python3;
in
python.pkgs.buildPythonApplication rec {
  pname = "gramps-webapi";
  version = "1.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps-webapi";
    rev = "v${version}";
    sha256 = "sha256-sOGzH7g9QVwPR4uTIIhMFikgeUa2yIj6Wz3f2cpPJvk=";
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

    ffmpeg-python
    sqlalchemy
    pdf2image
    redis
  ];

  # Upstream repo doesn't provide any tests.
  doCheck = false;

  meta = {
    description = "A RESTful web API for Gramps";
    homepage = "https://github.com/gramps-project/gramps-webapi/";
    # license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ robert ];
    # platforms = platforms.all;
  };
}
