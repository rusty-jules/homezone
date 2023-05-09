{ config, pkgs, ... }:
{
  # This installs the nvidia driver
  # It seems that this service installs a mix of packages, both necessary and unnecessary.
  # The root nvidia-linux driver is here:
  # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/pkgs/os-specific/linux/nvidia-x11/generic.nix#L125
  # We can test later if we can avoid installing X11 stuff along with the driver.
  services.xserver.videoDrivers = [ "nvidia" ];
  # This is required for some apps to see the driver
  hardware.opengl.enable = true;

  # This selects the Nvidia Driver version, GTX 1070 is not yet legacy!
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
}
