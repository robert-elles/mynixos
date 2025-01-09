{ pkgs, ... }: {

  services.stirling-pdf = {
    enable = true;
    environment = {
      INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
      SERVER_PORT = 2600;
    };
  };

  # nixpkgs.overlays = [
  #   (self: super: {
  #     stirling-pdf = super.stirling-pdf.overrideAttrs (old: rec {
  #       version = "0.36.6";
  #       src = pkgs.fetchFromGitHub {
  #         owner = "Stirling-Tools";
  #         repo = "Stirling-PDF";
  #         rev = "v${version}";
  #         hash = "sha256-Cl2IbFfw6TH904Y63YQnXS/mDEuUB6AdCoRT4G+W0hU=";
  #       };
  #     });
  #   })
  # ];
}
