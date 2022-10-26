{ ... }: {
  services.transmission = {
    enable = true;
    settings = {
      rpc-bind-address = "0.0.0.0";
      #              rpc-port = 9091;
      rpc-host-whitelist = "rpi4";
      rpc-whitelist = "192.168.178.*";
    };
  };
}
