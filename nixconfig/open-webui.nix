{ pkgs-pin, ... }:
{
  services.open-webui = {
    enable = true;
    port = 9092;
    host = "0.0.0.0";
    # package = pkgs-pin.open-webui;
  };
}
