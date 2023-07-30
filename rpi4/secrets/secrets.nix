let
  robert =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqJBNi0DfwZjFvjGLlapp7Kd57tpTDaPRZWU42R6gks";
  panther =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH/vzGOac1ezLbdc5oyRzLU2I9F6SLt6wRAxItAXsZO";
  rpi4 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Nc0x2ejrf96rft9KiuJR5+hQqAqXZ+9H5JqS7JyTz";
in
{
  "wireless.env.age".publicKeys = [ panther robert rpi4 ];
  "mopidy_extra.conf.age".publicKeys = [ panther robert rpi4 ];
  "rpi4.nix.age".publicKeys = [ panther robert rpi4 ];
  "dbpass.age".publicKeys = [ panther robert rpi4 ];
  "nextcloud_adminpass.age".publicKeys = [ panther robert rpi4 ];
  "data_disk_key.age".publicKeys = [ panther robert rpi4 ];
  "davfs2_secrets.age".publicKeys = [ panther robert rpi4 ];
  "grampsweb_config.cfg.age".publicKeys = [ panther robert rpi4 ];
}
