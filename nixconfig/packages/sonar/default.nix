{ lib
, buildGoModule
, fetchFromGitHub
,
}:

buildGoModule rec {
  pname = "sonar";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "raskrebs";
    repo = "sonar";
    tag = "v${version}";
    hash = "sha256-hX6CQke67xbf1gHEF/S3sphZ0d/GVMcGFLuitycVYg0=";
  };

  vendorHash = "sha256-komX1AmHt2NoF1x6xsNa2RFkfVzOXfYEMPhT0zwMxjw=";

  meta = {
    description = "CLI tool for inspecting and managing services listening on localhost ports";
    homepage = "https://github.com/raskrebs/sonar";
    license = lib.licenses.mit;
    mainProgram = "sonar";
  };
}
