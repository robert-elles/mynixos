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
  linger-user = "robert";
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
    #    wantedBy = [ "multi-user.target" ];
    wantedBy = [ "default.target" ];
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

  # must run the following:
  # loginctl enable-linger robert
  # This enables “lingering” for the CI user.
  # Inspired by the discussion (and linked code)
  # in https://github.com/NixOS/nixpkgs/issues/3702
  # This should just be a NixOS option really.
  system.activationScripts = {
    enableLingering = ''
      # remove all existing lingering users
      rm -r /var/lib/systemd/linger
      mkdir /var/lib/systemd/linger
      # enable for the subset of declared users
      touch /var/lib/systemd/linger/${linger-user}
    '';
  };

  services.avahi.enable = true;
  #  services.spotifyd.enable = true;
  #    services.spotifyd.settings = { global = { bitrate = 320; }; };

  environment.systemPackages = with pkgs; [ spotifyd ];
}
