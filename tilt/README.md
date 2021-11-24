# How to install latest tilt

https://nixos.wiki/wiki/Nixpkgs/Modifying_Packages 

Shallow git clone:

git clone --depth 1 https://github.com/robert-elles/nixpkgs.git

Go to ~/code/nixpkgs/pkgs/applications/networking/cluster/tilt/

Set sha256 = lib.fakeSha256;

to build execute:

nix-build -v

copy paste from the output the correct sha value


# as overlay

https://nixos.wiki/wiki/Overlays