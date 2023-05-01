{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cudatoolkit
    # enable nvidia-docker, which is oddly defined in multiple places
    # in nixpkgs. Guide here was great:
    # https://sebastian-staffa.eu/posts/nvidia-docker-with-nix/
    # https://github.com/NixOS/nixpkgs/blob/db3e8325a9b62b2b4fad0342f6835cb4ccc80c9b/pkgs/applications/virtualization/nvidia-docker/default.nix
    nvidia-docker
  ];

  # Nvidia Driver, GTX 1070 is not yet legacy!
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
