{ lib
, stdenv
, fetchFromGitHub
, cmake
, kdePackages
, nix-update-script
,
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "compact_pager";
  version = "v3.3-rc2";

  src = fetchFromGitHub {
    owner = "tilorenz";
    repo = "compact_pager";
    tag = version;
    hash = "sha256-Q7qSky/wY5l72EVhTGnwQ8lI3Uu3TnZpgqXaClCxWZQ=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    kdePackages.plasma-desktop
    kdePackages.kdeplasma-addons
  ];

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_PLASMOID" true)
    (lib.cmakeBool "BUILD_PLUGIN" true)
    (lib.cmakeFeature "Qt6_DIR" "${kdePackages.qtbase}/lib/cmake/Qt6")
  ];

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A compact pager (virtual desktop switcher) for the KDE Plasma desktop.";
    homepage = "https://github.com/tilorenz/compact_pager";
    license = lib.licenses.gpl3Only;
    # maintainers = with lib.maintainers; [ ];
    inherit (kdePackages.kwindowsystem.meta) platforms;
  };
})
