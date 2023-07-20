{ config, lib, pkgs, ... }:
let
  pypkgs = pkgs.python3.pkgs;
  cfg = config.services.gramps-web;
  inherit (lib) mkIf mkOption types mkEnableOption;
  gramps-webapi = pkgs.callPackage ../gramps-webapi { };
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
      environment = {
        PYTHONPATH = "${gramps-webapi.pythonPath}:${gramps-webapi}/lib/python3.10/site-packages/";
      };

      serviceConfig =
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart =
            let
              cmd = "${gramps-webapi.python.pkgs.gunicorn}/bin/gunicorn";
              # cmd = "gunicorn";
              # appPath = "${gramps-webapi}/gramps_webapi/wsgi:app";
              appPath = "gramps_webapi.wsgi:app";
            in
            ''
              ${cmd} -w 2 -b 0.0.0.0:5000 ${appPath}
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
