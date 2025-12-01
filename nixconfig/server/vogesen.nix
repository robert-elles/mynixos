{ ... }:
{
  virtualisation.oci-containers.containers = {
    vogesen-checklist = {
      image = "vogesen-checklist:0.5.1";
      ports = [ "7222:80" ];
    };
  };
}
