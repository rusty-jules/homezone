self: super:

{
  libnvidia-container = super.libnvidia-container.overrideAttrs (oldAttrs: {
    patches = [
      ./libnvidia-container.patch
      ./libnvidia-container-ldcache.patch
      (super.pkgs.path + "/pkgs/applications/virtualization/libnvidia-container/inline-c-struct.patch")
    ];

    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" src/common.h
    '';
  });

  nvidia-container-toolkit = super.nvidia-container-toolkit.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" internal/ldcache/ldcache.go
    '';
  });

  # https://discourse.nixos.org/t/using-nvidia-container-runtime-with-containerd-on-nixos/27865/3
  nvidia-k3s = with self.pkgs; mkNvidiaContainerPkg {
    name = "nvidia-k3s";
    containerRuntimePath = "runc";
    configTemplate = ./config.toml;
  };
}
