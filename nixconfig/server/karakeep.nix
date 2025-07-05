{ ... }: {

  services.karakeep = {
    enable = true;
    extraEnvironment = { PORT = "5200"; };
  };
}
