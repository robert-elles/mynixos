{ ... }:
let
  secrets_dir = ../../secrets/agenix;
in
{
  age.secrets = {
    # wireless.file = ./secrets/wireless.env.age;
    # mopidy_extra.file = ./secrets/mopidy_extra.conf.age;
    # data_disk_key.file = ./secrets/data_disk_key.age;
    ddclient_password.file = secrets_dir + /ddclient_password.age;
    # grampsweb_config = {
    #   file = ./secrets/grampsweb_config.cfg.age;
    #   owner = "robert";
    # };
    # davfs2_nc_secret = {
    #   file = ./secrets/davfs2_secrets.age;
    #   path = "/etc/davfs2/secrets";
    # };
    pgadmin = {
      file = secrets_dir + /pgadmin.age;
      mode = "770";
      owner = "pgadmin";
      group = "pgadmin";
    };
    dbpass = {
      file = secrets_dir + /dbpass.age;
      mode = "770";
      owner = "nextcloud";
      group = "nextcloud";
    };
    nextcloud_adminpass = {
      file = secrets_dir + /nextcloud_adminpass.age;
      mode = "770";
      owner = "nextcloud";
      group = "nextcloud";
    };
    immich_secrets = {
      file = secrets_dir + /immich_secrets.age;
      mode = "770";
      owner = "immich";
      group = "immich";
    };
    freshrss_password = {
      file = secrets_dir + /freshrss_password.age;
      mode = "770";
      owner = "freshrss";
      group = "freshrss";
    };
    navidrome = {
      file = secrets_dir + /navidrome.age;
      mode = "770";
      owner = "navidrome";
      group = "navidrome";
    };
    netbird_setup_key = {
      file = secrets_dir + /netbird_setup_key.age;
      mode = "770";
      owner = "netbird-wt0";
      group = "netbird-wt0";
    };
    guacamole_user_mapping = {
      file = secrets_dir + /guacamole_user_mapping.age;
      mode = "440";
      owner = "tomcat";
      group = "tomcat";
    };
    mealie_tls_key = {
      file = secrets_dir + /mealie_tls_key.age;
      mode = "440";
      owner = "nginx";
      group = "nginx";
    };
  };
}
