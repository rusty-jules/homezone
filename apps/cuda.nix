{ config, pkgs, ... }:
{
  # Nvidia Driver, GTX 1070 is not yet legacy!
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
