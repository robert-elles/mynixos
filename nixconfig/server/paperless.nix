{ config, ... }:
{

  age.secrets = {
    paperless_password = {
      file = ../../secrets/agenix/paperless_password.age;
      mode = "777";
      owner = "paperless";
      group = "paperless";
    };
  };

  services.paperless = {
    enable = true;
    dataDir = "/data/paperless/data";
    mediaDir = "/data/paperless/media";
    consumptionDir = "/data/paperless/consumption";
    user = "paperless";
    address = "0.0.0.0";
    passwordFile = "${config.age.secrets.paperless_password.path}";
  };
}
