{
  pkgs,
  config,
  settings,
  ...
}:
{
  services.dawarich = {
    enable = true;
    localDomain = "dawarich.${settings.public_hostname2}";
    # default port is 3000
  };
}
