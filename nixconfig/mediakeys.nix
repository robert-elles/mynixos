system_repo_root:
{ config, pkgs, ... }: {
  sound.mediaKeys.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -U 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "/run/current-system/sw/bin/light -A 10";
      }
      {
        keys = [ 171 ];
        events = [ "key" ];
        command = "${system_repo_root}/scripts/kdblight";
      }
    ];
  };
}
