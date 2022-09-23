{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "zed";
  version = "0.7.1";
  src = fetchFromGitHub {
    owner = "authzed";
    repo = "zed";
    rev = "v${version}";
    #          sha256 = lib.fakeSha256;
    hash = "sha256-tSJ/Bt6hWtuydyo4G2KDWkGQp1jguF/+r3PMDrk50K8=";
  };
  #  vendorSha256 = lib.fakeSha256;
  vendorSha256 = "sha256-AEU8yTG+n+JOSB7Cnmf+mztm/1c5vuarSqVr3hC/14g=";
  ldflags = [ "-X main.version=${version}" ];
}
