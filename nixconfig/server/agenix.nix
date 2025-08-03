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
  };
}
