{ settings, ... }:
{

  fileSystems."/var/lib/logstash" = {
    device = "/data/logstash";
    options = [
      "bind"
      "nofail"
      "async"
    ];
    neededForBoot = false;
    noCheck = true;
  };

  services.nginx.virtualHosts."${settings.hostname}".locations."/logstash".return = "301 http://${settings.hostname}:9292";

  services.logstash = {
    enable = true;
    listenAddress = "0.0.0.0";
    logLevel = "info";
  };
}
