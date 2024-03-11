{ pkgs, ... }:
# See: https://nixos.wiki/wiki/Actkbd
# journalctl --unit display-manager.service -b0 | grep "Adding input device" | sed -e 's;.*config/udev: ;;' | sort | uniq
let
  kdblight = pkgs.writeShellScriptBin "kdblight" ''
    #!/bin/sh
    backlight=$(/run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -G)
    if [ $backlight == "0.00" ]; then
        /run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -S 100
    else
        /run/current-system/sw/bin/light -s sysfs/leds/tpacpi::kbd_backlight -S 0
    fi
  '';
in
{
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
        command = "${kdblight}/bin/kdblight";
      }
      # shift + strg + right arrow
      # {
      #   keys = [ 29 42 106 ]; # strg + shift + right arrow
      #   events = [ "key" ];
      #   command = "sudo -u robert DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u robert)/bus playerctl next";
      # }
    ];
  };
}
