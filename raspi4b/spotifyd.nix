{ pkgs, ... }:
let
  spotifyd = pkgs.spotifyd;
  #  .override {
  #    withMpris = true;
  #    withPulseAudio = true;
  #  };
  spotifydConf = pkgs.writeText "spotifyd-config" ''
        [global]
    #    backend = "pulseaudio"
        bitrate = 320
        use_mpris = true
  '';
in {
  systemd.user.services.spotifyd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sound.target" ];
    description = "spotifyd, a Spotify playing daemon";
    serviceConfig = {
      ExecStart =
        "${spotifyd}/bin/spotifyd --cache-path=\${HOME}/.cache/spotifyd --config-path=${spotifydConf}";
      Restart = "always";
      RestartSec = 4;
    };
  };

  environment.systemPackages = with pkgs; [ spotifyd ];
}
