{ ... }: {
  services.mongodb = {
    enable = true;
    enableAuth = false;
    # initialRootPasswordFile = "YourSecurePassword";
    bind_ip = "0.0.0.0";
  };
}
