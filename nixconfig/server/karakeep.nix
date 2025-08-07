{ ... }:
{

  services.karakeep = {
    enable = true;
    extraEnvironment = {
      PORT = "5200";
      DISABLE_SIGNUPS = "true";
    };
  };
}
