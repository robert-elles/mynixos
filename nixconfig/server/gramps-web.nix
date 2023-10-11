{ config, ... }: {

  imports = [ ./web-apps/gramps-web.nix ];

  services.gramps-web.enable = true;
  services.gramps-web.user = "robert";
  services.gramps-web.config-file = "${config.age.secrets.grampsweb_config.path}";
  services.gramps-web.dataDir = "/data/grampsweb";
}

