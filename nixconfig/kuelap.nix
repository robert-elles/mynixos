{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    (callPackage ./my-spicedb-zed { buildGoModule = buildGo120Module; })
    google-cloud-sdk
    kubectl
    k9s
    kustomize
    smartgithg
    kube3d

  ];
}
