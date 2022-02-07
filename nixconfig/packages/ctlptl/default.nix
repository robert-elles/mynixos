{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "ctlptl";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "tilt-dev";
    repo = pname;
    rev = "v${version}";
    #    sha256 = lib.fakeSha256;
    sha256 = "sha256:0v79kkg3jxkfxr188sl9k742dimzg9c4cixbb11a5sdg5vkjyngh";
  };
  vendorSha256 = null;

  runVend = true;
  #  -mod=readonly or -mod=mod.
  buildFlagsArray = [ "-mod=mod" ];
  #  tags = [ "-mod=readonly" ];

  #  subPackages = [ "cmd/${pname}" ];

  deleteVendor = true;

  ldflags = [ "-X main.version=${version}" ];

  meta = with lib; {
    description = "Making local Kubernetes clusters fun and easy to set up";
    homepage = "https://github.com/tilt-dev/ctlptl";
    license = licenses.asl20;
    #    maintainers = with maintainers; [ anton-dessiatov ];
  };
}
