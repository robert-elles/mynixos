{ ... }: {
  services.elasticsearch = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9200;
    # logging.level = ''
    #   o.e.d.c.m.IndexNameExpressionResolver.level = error
    # '';
    # dataDir = "/var/lib/elasticsearch";
  };

  virtualisation.oci-containers.containers = {
    kibana = {
      image = "docker.elastic.co/kibana/kibana:7.2.1";
      ports = [ "5601:5601" ];
      environment = {
        SERVER_NAME = "kibana";
        ELASTICSEARCH_HOSTS = "http://falcon:9200";
      };
    };
  };
}
