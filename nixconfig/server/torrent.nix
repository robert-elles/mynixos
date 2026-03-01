{ pkgs, settings, ... }: {
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "robert";
    settings = {
      rpc-bind-address = "0.0.0.0";
      # rpc-port = 9091;
      rpc-host-whitelist = settings.hostname;
      rpc-whitelist = "192.168.178.*";
      download-dir = "/data2/";
      incomplete-dir-enabled = false;
      downloadDirPermissions = "777";
    };
  };
}
