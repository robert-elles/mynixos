{ ... }:
{
  virtualisation.oci-containers.containers = {
    vogesen-checklist = {
      image = "vogesen-checklist:0.7.2";
      ports = [ "7222:80" ];
    };
  };
}
