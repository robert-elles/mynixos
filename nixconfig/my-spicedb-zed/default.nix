{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "zed";
  version = "0.15.0";
  src = fetchFromGitHub {
    owner = "authzed";
    repo = "zed";
    rev = "v${version}";
    # sha256 = lib.fakeSha256;
    hash = "sha256-+YgGxqnHkdPbRbQj5o1+Hx259Ih07x0sdt6AHoD1UvI=";
  };
  #  vendorSha256 = lib.fakeSha256;
  vendorSha256 = "sha256-f0UNUOi0WXm06dko+7O00C0dla/JlfGlXaZ00TMX0WU=";
  ldflags = [ "-X main.version=${version}" ];
}
