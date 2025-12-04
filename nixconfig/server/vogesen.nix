{ ... }:
{
  virtualisation.oci-containers.containers = {
    vogesen-checklist = {
      image = "vogesen-checklist:0.5.5";
      ports = [ "7222:80" ];
    };
  };
}
