{ ... }: {

  networking.extraHosts = ''
    10.180.3.18 dev-srv-robert-elles gcpdevsrv
  '';

  virtualisation.docker.enable = true;
  #  virtualisation.docker.extraOptions = "--insecure-registry 10.180.3.2:5111 ";
  #  virtualisation.docker.extraOptions =
  #    "--insecure-registry registry.devsrv.kuelap.io:80 ";
  virtualisation.docker.daemon.settings = {
    insecure-registries = [
      "registry.devsrv.kuelap.io:80"
      "gcpdevsrv:5111"
      "10.180.3.18:5111"
    ];
  };
}
