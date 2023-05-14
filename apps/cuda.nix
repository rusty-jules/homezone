{ config, pkgs, lib, ... }:

let
  unpatched-nvidia-driver = (config.hardware.nvidia.package.overrideAttrs (oldAttrs: {
    builder = ../overlays/nvidia-builder.sh;
  }));

  runtime-config = pkgs.runCommandNoCC "config.toml" {
    src = ../overlays/config.toml;
  } ''
    cp $src $out
    substituteInPlace $out \
      --subst-var-by glibcbin ${lib.getBin pkgs.glibc}
  '';
in
{
  environment.systemPackages = with pkgs; [
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#id6
    # https://itnext.io/enabling-nvidia-gpus-on-k3s-for-cuda-workloads-a11b96f967b0
    nvidia-container-toolkit
    nvidia-container-runtime
    cudaPackages.fabricmanager
    cudaPackages.cuda_nvml_dev
    runc
  ];

  environment.etc = {
    "nvidia-container-runtime/config.toml" = {
      source = runtime-config;
      mode = "0600";
    };
  };

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
  # Required to keep GPU awake for runtime
  hardware.nvidia.nvidiaPersistenced = true;

  # needed for ldconfig files
  systemd.services.k3s.serviceConfig.PrivateTmp = true;

  # add nvidia pkgs to k3s PATH
  systemd.services.k3s.path = with pkgs; [
    glibc # for ldconfig in preStart
    nvidia-container-toolkit
    nvidia-container-runtime
    unpatched-nvidia-driver
    cudaPackages.fabricmanager
    cudaPackages.cuda_nvml_dev
    runc
  ];

  # FIXME: this resulted in a systemd unit stop crash loop
  ## here we can initialize the ld cache that nvidia requires
  # https://discourse.nixos.org/t/using-nvidia-container-runtime-with-containerd-on-nixos/27865/6
  systemd.services.k3s.preStart = ''
    rm -rf /tmp/nvidia-libs
    mkdir -p /tmp/nvidia-libs

    for LIB in {${unpatched-nvidia-driver}/lib/*,${pkgs.nvidia-container-toolkit}/lib/*,${pkgs.libtirpc}/lib/*,${pkgs.cudaPackages.cuda_nvml_dev}/lib/stubs/*}; do
      ln -s -f $(readlink -f $LIB) /tmp/nvidia-libs/$(basename $LIB)
    done

    echo "initializing nvidia ld cache"
    ldconfig -C /tmp/ld.so.cache /tmp/nvidia-libs

    echo "nvidia ld cache contents"
    ldconfig -C /tmp/ld.so.cache --print-cache
  '';
}
