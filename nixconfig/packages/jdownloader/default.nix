{ lib, stdenv, fetchFromGitHub, makeDesktopItem, jdk, ... }:

stdenv.mkdDerivation {

  desktopItem = makeDesktopItem {
    name = "JDownloader";
    exec = "";
    icon = "";
    comment = "Download Manager";
    desktopName = "JDownloader";
    genericName = "Download Manager";
    categories = [ "Internet" ];
  };


  src = fetchFromGitHub {
    owner = "mirror";
    repo = "jdownloader";
    rev = "";
    sha256 = lib.fakeSha256;
    # sha256 = "sha256:0v79kkg3jxkfxr188sl9k742dimzg9c4cixbb11a5sdg5vkjyngh";
  };

  nativeBuildInputs = [ jdk ];

  buildInputs = [
    jdk
  ];

  meta = {
    homepage = "https://jdownloader.org/home/index";
    description = "Open source download manager";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}

