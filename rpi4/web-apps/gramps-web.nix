{ config, lib, pkgs, ... }:
let
  cfg = config.services.gramps-web;
  inherit (lib) mkIf mkOption types mkEnableOption;
  gramps-webapi = pkgs.callPackage ../gramps-webapi { };
  grampsjs = pkgs.callPackage ../gramps.js { };
  gramps = pkgs.gramps;
in
{
  options = {
    services.gramps-web = {

      enable = mkEnableOption (lib.mdDoc "Gramps-Web");

      config-file = mkOption {
        type = types.path;
        # default = "";
        description = lib.mdDoc "The path to the .cfg config file.";
      };

      user = mkOption {
        type = types.str;
        default = "gramps-web";
        description = lib.mdDoc "User account under which gramps-web runs.";
      };

      group = mkOption {
        type = types.str;
        default = "gramps-web";
        description = lib.mdDoc "Group account under which gramps-web runs.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = lib.mdDoc ''
          Open ports in the firewall for the server.
        '';
      };

      dataDir = mkOption {
        type = types.str;
        default = "gramps-web";
        description = lib.mdDoc ''
          The where gramps-web stores its data.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.gramps-web = {
      description = "Web app for collaborative genealogy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PYTHONPATH = "${gramps-webapi.pythonPath}:${gramps-webapi}:${gramps}/lib/python3.10/site-packages/";
        GRAMPS_API_CONFIG = cfg.config-file;
        GRAMPSWEB_SEARCH_INDEX_DIR = "${cfg.dataDir}/index";
        GRAMPSWEB_MEDIA_BASE_DIR = "${cfg.dataDir}/media";
        GRAMPSWEB_MEDIA_REPORT_DIR = "${cfg.dataDir}/reports";
        GRAMPSWEB_MEDIA_EXPORT_DIR = "${cfg.dataDir}/exports";
        GRAMPSWEB_STATIC_PATH = "${grampsjs}/dist/";
        GRAMPSWEB_CORS_ORIGINS = "*";
      };

      preStart =
        let
          pycmd = "${gramps-webapi.python}/bin/python -m gramps_webapi --config ${cfg.config-file}";
        in
        ''
          if [ ! -d "${cfg.dataDir}/index" ]; then
            mkdir ${cfg.dataDir}/index
          fi

          if [ ! -d "${cfg.dataDir}/media" ]; then
            mkdir ${cfg.dataDir}/media
          fi

          if [ ! -d "${cfg.dataDir}/reports" ]; then
            mkdir ${cfg.dataDir}/reports
          fi

          if [ ! -d "${cfg.dataDir}/exports" ]; then
            mkdir ${cfg.dataDir}/exports
          fi

          cd ${gramps-webapi}

          # Create search index if not exists
          if [ -z "$(ls -A ${cfg.dataDir}/index)" ]
          then
              echo "Create the search index"
              ${pycmd} search index-full
          fi

          # Run migrations for user database, if any
          ${pycmd} user migrate
        '';

      serviceConfig =
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart =
            let
              cmd = "${gramps-webapi.python.pkgs.gunicorn}/bin/gunicorn";
              appPath = "gramps_webapi.wsgi:app";
            in
            ''
              ${cmd} --workers=2 -b 0.0.0.0:5049 ${appPath}
            '';
          Restart = "on-failure";
        };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listen.port ];
    };

    users.users = mkIf (cfg.user == "gramps-web") {
      gramps-web = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = mkIf (cfg.group == "gramps-web") {
      gramps-web = { };
    };
  };
}
