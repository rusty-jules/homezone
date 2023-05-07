{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # cudatoolkit
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#id6
    # https://itnext.io/enabling-nvidia-gpus-on-k3s-for-cuda-workloads-a11b96f967b0
    # nvidia-container-toolkit-base
  ];

  # Nvidia Driver, GTX 1070 is not yet legacy!
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
