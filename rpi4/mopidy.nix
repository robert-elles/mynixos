{ config, pkgs, ... }: {
  # mopidy

  nixpkgs.overlays = [ (import ./iris_overlay.nix) ];

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      #      mopidy-spotify
      #      pkgs-custom.mopidy-iris
      mopidy-iris
      mopidy-youtube
      mopidy-moped
      #      mopidy-Mopify
      #      mopidy-soundcloud
    ];
    extraConfigFiles = [ config.age.secrets.mopidy_extra.path ];
    configuration = ''
                  #      [local]
                  #      enabled = true
                  #      media_dir = /data/nextcloud/nextcloud/data/robert/files/Music

                  [http]
                  enabled = true
                  hostname = 0.0.0.0
                  port = 6680

                  [spotify]
                  enabled = true
                  bitrate = 320

                  [audio]
                  #output = pulsesink server=127.0.0.1
                  #output = pulsesink device=1
                  #output = alsasink
                  #output = autoaudiosink
                  output = pulsesink
                  mixer = software

      #            [youtube]
      #            enabled = true
      #            #autoplay_enabled = true
      #            youtube_api_key = parameters.mopidy.youtube_api_key
      #            api_enabled = true

                  [mpd]
                  enabled = true
                  hostname = 0.0.0.0
                  zeroconf = mpd
                  port = 6610
                  connection_timeout = 240

            #      [file]
            #      enabled = true
            #      media_dirs = /data/nextcloud/nextcloud/data/robert/files/Music
            #      show_dotfiles = false
            #      excluded_file_extensions =
            #        .directory
            #        .html
            #        .jpeg
            #        .jpg
            #        .log
            #        .nfo
            #        .pdf
            #        .png
            #        .txt
            #        .zip
            #      follow_symlinks = false
            #      metadata_timeout = 1000

                  [mowecl]
                  enabled = true

                  # generic config
                  seek_update_interval = 500
                  search_history_length = 10

                  # theme config
                  ## light or dark
                  theme_type = dark
                  #background_color = #fdf6e3
                  #text_color = #002b36
                  #primary_color = #268bd2


      #            [soundcloud]
      #            auth_token = parameters.mopidy.soundcloud_auth_token
      #            explore_songs = 25

                  [iris]
                  country = DE
                  locale = de_DE
    '';
  };
}
