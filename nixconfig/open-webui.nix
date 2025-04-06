{ ... }: {
  services.open-webui = {
    enable = true;
    port = 9092;
    host = "0.0.0.0";
  };
}
