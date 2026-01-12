{
  settings,
  pkgs,
  config,
  ...
}:
{

  services.navidrome = {
    enable = true;
    settings = {
      address = "::";
      port = 4533;
      EnableInsightsCollector = true;
      MusicFolder = "/data/music";
      BaseUrl = "https://navidrome.${settings.public_hostname2}";
      Scanner.Enabled = true;
      LogLevel = "error";
    };
    environmentFile = config.age.secrets.navidrome.path;
  };
}
