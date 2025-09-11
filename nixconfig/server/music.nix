{ ... }:
{

  services.navidrome = {
    enable = true;
    settings = {
      address = "0.0.0.0";
      port = 4533;
    };
  };
}
