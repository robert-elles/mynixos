{ ... }: {
  services.atuin = {
    enable = true;
    port = 8060;
    host = "0.0.0.0";
  };
}
