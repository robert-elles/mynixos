{ ... }:
{
  services.nfs.server = {
    enable = true;
    exports = ''
      /export         192.168.178.0/24(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)
      /export/movies    192.168.178.0/24(insecure,rw,sync,no_subtree_check) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check)
      /export/tvshows    192.168.178.0/24(insecure,rw,sync,no_subtree_check) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check)
      /export/downloads    192.168.178.0/24(insecure,rw,sync,no_subtree_check) 2003:d1:4708:4400::/64(insecure,rw,sync,no_subtree_check)
    '';
  };

  # bind mounts for nfs share
  fileSystems."/export/movies" = {
    device = "/data2/movies";
    options = [ "bind" ];
  };

  fileSystems."/export/tvshows" = {
    device = "/data2/tvshows";
    options = [ "bind" ];
  };

  fileSystems."/export/downloads" = {
    device = "/data2/downloads";
    options = [ "bind" ];
  };
}
