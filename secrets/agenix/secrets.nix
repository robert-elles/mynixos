# find out the right key with e.g.: ssh-keyscan falcon
let
  robert = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqJBNi0DfwZjFvjGLlapp7Kd57tpTDaPRZWU42R6gks";
  falcon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIZkjQFSIcLmRvJNIlUZTpxt3NjczxgkitOkgirfTDN";
  panther =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJH/vzGOac1ezLbdc5oyRzLU2I9F6SLt6wRAxItAXsZO";
  rpi4 =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Nc0x2ejrf96rft9KiuJR5+hQqAqXZ+9H5JqS7JyTz";
  # keys = [ panther robert rpi4 ];
  keys = [ robert falcon ];
in
{
  "wireless.env.age".publicKeys = keys;
  "mopidy_extra.conf.age".publicKeys = keys;
  "rpi4.nix.age".publicKeys = keys;
  "dbpass.age".publicKeys = keys;
  "nextcloud_adminpass.age".publicKeys = keys;
  "data_disk_key.age".publicKeys = keys;
  "davfs2_secrets.age".publicKeys = keys;
  "grampsweb_config.cfg.age".publicKeys = keys;
  "paperless_password.age".publicKeys = keys;
}
