{ ... }:
{
  virtualisation.oci-containers.containers = {
    vogesen-checklist = {
      image = "vogesen-checklist:0.6.5";
      ports = [ "7222:80" ];
    };
  };
}
