{ lib
, osConfig
, pkgs
, ...
}:
let
  toLanguagePack =
    locales:
    map
      (
        locale: builtins.replaceStrings [ "_" ] [ "-" ] (lib.strings.removeSuffix ".UTF-8/UTF-8" locale)
      )
      locales;
in
{

  programs.firefox = {
    enable = true;

    betterfox = {
      enable = true;
      version = "main";
    };

    languagePacks = toLanguagePack osConfig.i18n.supportedLocales;
    nativeMessagingHosts = lib.optionals osConfig.services.desktopManager.plasma6.enable [
      pkgs.kdePackages.plasma-browser-integration
    ];

    profiles.robert = {
      isDefault = true;
      name = "Robert Elles";

      betterfox = {
        enable = true;
        enableAllSections = true;
        smoothfox = {
          enable = true;
          instant-scrolling.enable = true;
        };
      };
      settings = {

        # Enable DRM by default
        "browser.eme.ui.enabled" = true;
        "media.eme.enabled" = true;
      };

      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        [
          plasma-integration
          #   betterttv
          #   bitwarden
          #   catppuccin-gh-file-explorer
          #   darkreader
          #   dearrow
          #   firefox-color
          #   return-youtube-dislikes
          #   skip-redirect
          #   sponsorblock
          #   stylus
          #   ublock-origin
          violentmonkey
        ]
        ++
        lib.optionals osConfig.services.desktopManager.plasma6.enable [
          pkgs.kdePackages.plasma-integration
        ];

      # search = {
      #   force = true;
      #   default = "DuckDuckGo";
      #   privateDefault = "DuckDuckGo";

      #   engines =
      #     let
      #       mkEngine = alias: template: {
      #         definedAliases = [ "@${alias}" ];
      #         urls = [{ inherit template; }];
      #       };
      #     in
      #     {
      #       "DuckDuckGo" = mkEngine "duckduckgo" "https://duckduckgo.com/?q={searchTerms}";
      #       "Google" = mkEngine "google" "https://www.google.com/search?q={searchTerms}";
      #       "Noogle" = mkEngine "noogle" "https://noogle.dev/q?term={searchTerms}";
      #       "Bing".metaData.hidden = true;
      #     };
      # };
    };
  };
}
