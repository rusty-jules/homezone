self: super:

{
  super.packageOverrides = super: {
    cudaPackages.fabricmanager = super.cudaPackages.fabricmanager.override {
      attrs.version = "525.85.12";
      attrs."linux-x86_64" = {
        relative_path = "fabricmanager/linux-x86_64/fabricmanager-linux-x86_64-525.85.12-archive.tar.xz";
        sha256 = "0x0czlzhh0an6dh33p84hys4w8nm69irwl30k1492z1lfflf3rh1";
      };
    };
  };

  # https://discourse.nixos.org/t/using-nvidia-container-runtime-with-containerd-on-nixos/27865/3
  nvidia-k3s = with self.pkgs; mkNvidiaContainerPkg {
    name = "nvidia-k3s";
    containerRuntimePath = "runc";
    configTemplate = ./config.toml;
  };

  libnvidia-container = super.libnvidia-container.overrideAttrs (oldAttrs: {
    version = flakes.libnvidia-container.version;
    src = flakes.libnvidia-container.path;

    patches = [
      ./libnvidia-container.patch
      ./libnvidia-container-ldcache.patch
      (flakes.nixpkgs.path + "/pkgs/applications/virtualization/libnvidia-container/inline-c-struct.patch")
    ];

    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" src/common.h
    '';
  });

  nvidia-container-toolkit = super.nvidia-container-toolkit.overrideAttrs (oldAttrs: {
    version = flakes.nvidia-container-toolkit.version;
    src = flakes.nvidia-container-toolkit.path;

    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" internal/ldcache/ldcache.go
    '';
  });
}
