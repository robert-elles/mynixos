{ ... }: {
  services.transmission = {
    enable = true;
    user = "robert";
    settings = {
      rpc-bind-address = "0.0.0.0";
      # rpc-port = 9091;
      rpc-host-whitelist = "falcon";
      rpc-whitelist = "192.168.178.*";
      download-dir = "/data2/downloads";
      incomplete-dir-enabled = false;
      downloadDirPermissions = "777";
    };
  };
}
