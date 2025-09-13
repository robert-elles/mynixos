{ settings, pkgs, ... }:
{

  services.navidrome = {
    enable = true;
    settings = {
      address = "::";
      port = 4533;
      EnableInsightsCollector = true;
      MusicFolder = "/data/music";
    };
    environmentFile = pkgs.writeText "navidrome.env" ''
      ND_LOGLEVEL=error
      ND_BASEURL=https://navidrome.${settings.public_hostname2}
      ND_SCANNER_ENABLED=true
      ND_SCANNER_SCANONSTARTUP=true
      # ND_SCANNER_SCHEDULE=* * * * *
      ND_SCANNER_WATCHERWAIT=5s
      # ND_SCANNER_PURGEMISSING=always
    '';
  };
}
