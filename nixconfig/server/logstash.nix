{ ... }:
{

  fileSystems."/var/lib/logstash" = {
    device = "/data/logstash";
    options = [ "bind" ];
    neededForBoot = false;
    noCheck = true;
  };

  services.nginx.virtualHosts."falcon".locations."/logstash".return = "301 http://falcon:9292";

  services.logstash = {
    enable = true;
    listenAddress = "0.0.0.0";
    logLevel = "info";
  };
}
