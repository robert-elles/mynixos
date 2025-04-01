{ ... }: {
  fileSystems = {

    "/data" = {
      device = "/dev/disk/by-label/DATA";
      fsType = "ext4";
      options = [ "noatime" "async" "nofail" ];
    };
    "/data2" = {
      device = "/dev/disk/by-label/silverdisk";
      fsType = "ext4";
      options = [ "noatime" "async" "nofail" ];
    };
    "/data3" = {
      device = "/dev/disk/by-label/usb1";
      fsType = "ext4";
      options = [ "noatime" "async" "nofail" ];
    };
    # "/data_crypt" = {
    #   encrypted.enable = true;
    #   encrypted.label = "DATA_CRYPT";
    #   # device = "/dev/disk/by-label/DATA";
    #   # encrypted.blkDev = "/dev/disk/by-label/DATA_CRYPT";
    #   encrypted.keyFile = config.age.secrets.data_disk_key.path;
    #   fsType = "ext4";
    #   options = [ "noatime" "async" "nofail" ];
    # };
  };
}
