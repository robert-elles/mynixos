{ config, settings, ... }:
let
  secrets = import (settings.system_repo_root + "/secrets/gitcrypt/ddclient_secrets.nix");
in
{

  services.ddclient = {
    enable = true;
    # inherit secrets.username, secrets.password secrets.use secrets.server secrets.domains;
    username = secrets.username;
    passwordFile = config.age.secrets.ddclient_password.path;
    usev4 = secrets.usev4;
    usev6 = secrets.usev6;
    server = secrets.server;
    domains = secrets.domains;
    ssl = true;
    protocol = "dyndns2";
    interval = "6min"; # 10min 
  };
}
