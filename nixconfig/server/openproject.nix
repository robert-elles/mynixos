{ pkgs, settings, ... }: {

  services.nginx.virtualHosts = {
    "openproject.${settings.public_hostname2}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:3458";
        proxyWebsockets = true;
      };
    };
  };

  services.postgresql = {
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
    '';
    identMap = ''
      openproject_map root postgres 
      openproject_map app openproject     
    '';
    ensureUsers = [
      {
        name = "openproject";
        ensureDBOwnership = true;
      }
      {
        name = "app";
      }
    ];
  };

  users = {
    groups = {
      openproject = { };
    };
    users = {
      app = {
        isSystemUser = true;
        group = "openproject";
      };
      openproject = {
        isSystemUser = true;
        group = "openproject";
      };
    };
  };

  # systemd.services.docker-openproject-seeder.serviceConfig.Type = "oneshot";  

  virtualisation.oci-containers.containers = {
    cache = {
      image = "memcached";
    };
    openproject-seeder = {
      image = "openproject/openproject:14-slim";
      environment = {
        DATABASE_URL = "postgres:///openproject?user=openproject&pool=10&encoding=unicode&reconnect=true";
        RAILS_CACHE_STORE = "memcache";
        OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
        OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "-";
        RAILS_MIN_THREADS = "4";
        RAILS_MAX_THREADS = "10";
      };
      entrypoint = "./docker/prod/seeder";
      # restartPolicy = " on-failure";    
      volumes = [
        "/var/run/postgresql/.s.PGSQL.5432:/var/run/postgresql/.s.PGSQL.5432"
      ];
    };
    openproject-web = {
      image = "openproject/openproject:14-slim";
      environment = {
        OPENPROJECT_HTTPS = "true";
        # OPENPROJECT_HOST__NAME = "openproject.${settings.public_hostname2}";
        OPENPROJECT_HOST__NAME = "\${OPENPROJECT_HOST__NAME:-localhost:8080}";
        OPENPROJECT_DB_USERNAME = "openproject";
        DATABASE_URL = "postgres:///openproject?user=openproject&pool=10&encoding=unicode&reconnect=true";
        # OPENPROJECT_HSTS: "${OPENPROJECT_HSTS:-true}"     
        RAILS_CACHE_STORE = "memcache";
        OPENPROJECT_CACHE__MEMCACHE__SERVER = "cache:11211";
        OPENPROJECT_RAILS__RELATIVE__URL__ROOT = "-";
        RAILS_MIN_THREADS = "4";
        RAILS_MAX_THREADS = "10";
      };
      entrypoint = "./docker/prod/web";
      # extraOptions = [ "--network=host" ];    
      # memoryLimit = "1G";
      # cpuQuota = 100000;  
      # cpuPeriod = 100000;
      dependsOn = [ "cache" "openproject-seeder" ];
      # restartPolicy = "always";
      ports = [ "3458:8080" ];
      # user = "openproject:openproject";
      volumes = [
        # "/home/robert/code/mynixos/secrets/ gitcrypt/.env:/.env"
        "/var/run/postgresql/.s.PGSQL.5432:/var/run/postgresql/.s.PGSQL.5432"
        # "/fastdata/openproject:"
      ];
    };

    # openproject-worker = {
    #   image = "openproject/openproject:14-slim";
    #   environment = {
    #     OPENPROJECT_HTTPS = "true";
    #     OPENPROJECT_HOST__NAME = "openproject.${settings.public_hostname2}}";
    #     OPENPROJECT_DB_USERNAME = "openproject";
    #     DATABASE_URL = "postgres:///openproject?user=openproject&pool=10&encoding=unicode&reconnect=true";
    #     # OPENPROJECT_HSTS: "${OPENPROJECT_HSTS:-true}"
    #   };
    #   entrypoint = "./docker/prod/worker";
    #   # extraOptions = [ "--network=host" ];    
    #   # memoryLimit = "1G";
    #   # cpuQuota = 100000;          
    #   # cpuPeriod = 100000;
    #   dependsOn = [ "openproject-seeder" ];
    #   # restartPolicy = "always";
    #   # ports = [ "3458:8080" ];
    #   # user = "openproject:openproject";
    #   volumes = [
    #     # "/home/robert/code/mynixos/secrets/ gitcrypt/.env:/.env"
    #     "/var/run/postgresql/.s.PGSQL.5432:/var/run/postgresql/.s.PGSQL.5432"
    #     # "/fastdata/openproject:"
    #   ];
    # };
  };

  # systemd.timers."openproject_backup" = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "15m";
  #     OnUnitActiveSec = "90m";
  #     # OnCalendar = "*-*-* 4:00:00 Europe/Berlin";
  #     Unit = "openproject_backup.service";
  #   };
  # };

  # systemd.services."openproject_backup" = {
  #   script = ''
  #     set -eu
  #     ${pkgs.rsync}/bin/rsync -rvha --delete /fastdata/openproject/ /data2/openproject/
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };
}
