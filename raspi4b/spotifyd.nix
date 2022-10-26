{ pkgs, ... }:
let
  spotifyd = pkgs.spotifyd;
  #  .override {
  #    withMpris = true;
  #    withPulseAudio = true;
  #  };
  spotifydConf = pkgs.writeText "spotifyd-config" ''
    [global]
    bitrate = 320
    use_mpris = true
  '';
in {

  #  users = {
  #    users.spotifyd = {
  #      #      isSystemUser = true;
  #      isNormalUser = true;
  #      home = "/home/spotifyd";
  #      createHome = true;
  #      description = "spotifyd";
  #      group = "spotifyd";
  #      shell = pkgs.bash;
  #      extraGroups = [ "audio" "video" "networkmanager" ];
  #    };
  #    #    groups.spotifyd = { };
  #  };
  #
  systemd.user.services.spotifyd = {
    wantedBy = [ "multi-user.target" ];
    #        wantedBy = [ "default.target" ];
    after = [ "network-online.target" "sound.target" ];
    description = "spotifyd, a Spotify playing daemon";
    serviceConfig = {
      ExecStart =
        "${spotifyd}/bin/spotifyd --no-daemon --bitrate 320 --cache-path=\${HOME}/.cache/spotifyd";
      #        "${spotifyd}/bin/spotifyd --no-daemon --cache-path=\${HOME}/.cache/spotifyd --config-path=${spotifydConf}";
      Restart = "always";
      RestartSec = 12;
      #      DynamicUser = true;
      #      User = "robert";
      #      SupplementaryGroups = [ "audio" ];
    };
  };

  services.avahi.enable = true;
  #  services.spotifyd.enable = true;
  #    services.spotifyd.settings = { global = { bitrate = 320; }; };

  environment.systemPackages = with pkgs; [ spotifyd ];
}
