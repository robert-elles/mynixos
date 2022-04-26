{ }: {
  nixpkgs.overlays = [
    (self: super: {
      anki-bin = super.anki-bin.overrideAttrs (oldAttrs: rec {
        pname = "anki-bin";
        version = "2.1.50";
        sources = {
          linux = super.fetchurl {
            url =
              "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-qt6.tar.zst";
            #            url =
            #              "https://github.com/ankitects/anki/releases/download/2.1.50/anki-2.1.50-linux-qt6.tar.zst";
            sha256 = "sha256-lnGjbGNUK8QFbIP0LWcmUQQUfaQkYWK0OYgncpR3d24=";
          };
        };

        unpacked = super.stdenv.mkDerivation {
          inherit pname version;

          nativeBuildInputs = [ super.zstd ];
          src = sources.linux;

          installPhase = ''
            runHook preInstall
            xdg-mime () {
              echo Stubbed!
            }
            export -f xdg-mime
            PREFIX=$out bash install.sh
            runHook postInstall
          '';
        };
      });
    })
  ];
}
