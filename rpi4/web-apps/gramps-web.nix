{ config, lib, pkgs, ... }:
let
  cfg = config.services.gramps-web;
  inherit (lib) mkIf mkOption types mkEnableOption;
in
{
  options = {
    services.gramps-web = {

      enable = mkEnableOption (lib.mdDoc "Gramps-Web");

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
          The directory below {file}`/var/lib` where gramps-web stores its data.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.gramps-web = {
      description = "Web app for collaborative genealogy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;

        #     StateDirectory = cfg.dataDir;
        #     # ExecStartPre = pkgs.writeShellScript "gramps-web-pre-start" (
        #     #   ''
        #     #     __RUN_MIGRATIONS_AND_EXIT=1 ${calibreWebCmd}

        #     #     ${pkgs.sqlite}/bin/sqlite3 ${appDb} "update settings set ${settings}"
        #     #   '' + optionalString (cfg.options.calibreLibrary != null) ''
        #     #     test -f "${cfg.options.calibreLibrary}/metadata.db" || { echo "Invalid Calibre library"; exit 1; }
        #     #   ''
        #     # );

        ExecStart = ''
          ${pkgs.python3.pkgs.gunicorn}/bin/gunicorn -w 2 -b 0.0.0.0:5000
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
