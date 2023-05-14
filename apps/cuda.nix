{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#id6
    # https://itnext.io/enabling-nvidia-gpus-on-k3s-for-cuda-workloads-a11b96f967b0
    nvidia-container-toolkit
    nvidia-container-runtime
  ];
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

  # needed for ldconfig files
  systemd.services.k3s.serviceConfig.PrivateTmp = true;

  # add nvidia pkgs to k3s PATH
  systemd.services.k3s.path = with pkgs; [
    nvidia-container-toolkit
    nvidia-container-runtime
    config.hardware.nvidia.package
  ];

  # FIXME: this resulted in a systemd unit stop crash loop
  ## here we can initialize the ld cache that nvidia requires
  systemd.services.k3s.preStart = ''
    rm -rf /tmp/nvidia-libs
    mkdir -p /tmp/nvidia-libs

    for l in ${config.hardware.nvidia.package}/lib/*; do
      ln -s $(readlink -f $l) /tmp/nvidia-libs/$(basename $l)
    done

    echo "initializing nvidia ld cache"
    ldconfig -C /tmp/ld.so.cache /tmp/nvidia-libs

    echo "nvidia ld cache contents"
    ldconfig -C /tmp/ld.so.cache --print-cache
  '';
}
