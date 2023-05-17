self: super:
let
  unpatched-nvidia-driver = (self.pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_production.overrideAttrs (oldAttrs: {
    builder = ../overlays/nvidia-builder.sh;
  }));
in
{
  # cudaPackages = super.cudaPackages // {
  #   fabricmanager = super.cudaPackages.fabricmanager.overrideAttrs (oldAttrs: {
  #     version = "525.85.12";
  #     linux-x86_64 = {
  #       relative_path = "fabricmanager/linux-x86_64/fabricmanager-linux-x86_64-525.85.12-archive.tar.xz";
  #       sha256 = "0x0czlzhh0an6dh33p84hys4w8nm69irwl30k1492z1lfflf3rh1";
  #     };
  #   });
  # };

  libnvidia-container = (self.pkgs.callPackage (super.pkgs.path + "/pkgs/applications/virtualization/libnvidia-container") {}).overrideAttrs (oldAttrs: {
    version = "1.13.1";

    patches = [
      ./libnvc-ldcache-1.9.0.patch
      #./libnvidia-container-ldcache.patch
      (super.pkgs.path + "/pkgs/applications/virtualization/libnvidia-container/inline-c-struct.patch")
    ];

    postPatch = (oldAttrs.postPatch or "") + ''
      sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" src/common.h
    '';

    postInstall = 
    let
      inherit (super.pkgs.addOpenGLRunpath) driverLink;
      libraryPath = self.lib.makeLibraryPath [ 
        # unpatched-nvidia-driver
        (self.lib.getBin self.pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_production)
        "$out" driverLink "${driverLink}-32"
      ];
      binPath = self.lib.makeBinPath [
        (self.lib.getBin self.pkgs.glibc) # for ldconfig in preStart
        # (self.lib.getBin unpatched-nvidia-driver)
        (self.lib.getBin self.pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_production)
        self.pkgs.cudaPackages.fabricmanager
      ];
    in
    ''
      remove-references-to -t "${self.pkgs.go}" $out/lib/libnvidia-container-go.so.1.9.0
      wrapProgram $out/bin/nvidia-container-cli --prefix LD_LIBRARY_PATH : ${libraryPath} \
        --set PATH ${binPath}
    '';
  });

  nvidia-container-runtime = (super.pkgs.callPackage (super.pkgs.path + "/pkgs/applications/virtualization/nvidia-container-runtime") {
    inherit (super) lib;
    inherit (super.pkgs) fetchFromGitHub buildGoPackage makeWrapper linkFarm writeShellScript glibc;
    containerRuntimePath = "runc";
    configTemplate = ./config.toml;
  }).overrideAttrs (oldAttrs: {
    version = "3.5.0";
    # postPatch = (oldAttrs.postPatch or "") + ''
    #   sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" internal/ldcache/ldcache.go
    # '';
  });

  nvidia-container-toolkit = (super.pkgs.callPackage (super.pkgs.path + "/pkgs/applications/virtualization/nvidia-container-toolkit") {
    inherit (super) lib;
    inherit (super.pkgs) fetchFromGitHub buildGoModule makeWrapper;
    inherit (self) nvidia-container-runtime;
  }).overrideAttrs (oldAttrs: {
    version = "1.13.1";

    # postPatch = (oldAttrs.postPatch or "") + ''
    #   sed -i "s@/etc/ld.so.cache@/tmp/ld.so.cache@" internal/ldcache/ldcache.go
    # '';
  });

  nvidia-k3s = self.pkgs.symlinkJoin {
    name = "nvidia-k3s";
    paths = [
      self.libnvidia-container
      self.nvidia-container-toolkit
      self.nvidia-container-runtime
    ];
  };

  # nvidia-k3s = with self.pkgs; mkNvidiaContainerPkg {
  #   name = "nvidia-k3s";
  #   containerRuntimePath = "runc";
  #   configTemplate = ./config.toml;
  # };
}
