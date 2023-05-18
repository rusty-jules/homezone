self: super:
let
  inherit (super.pkgs) callPackage;
  virtualization = super.pkgs.path + "/pkgs/applications/virtualization";
  unpatched-nvidia-driver = (super.pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_production.overrideAttrs (oldAttrs: {
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

  libnvidia-container = import ./libnvidia-container.nix {
    inherit (self) stdenv lib;
    inherit (self.pkgs)
      addOpenGLRunpath fetchFromGitHub glibc pkg-config
      libelf libcap libseccomp libtirpc rpcsvc-proto
      makeWrapper substituteAll removeReferencesTo go;
    inherit (self.pkgs.cudaPackages) fabricmanager;
    inherit unpatched-nvidia-driver;
  };

  nvidia-container-toolkit = import ./nvidia-container-toolkit.nix {
    inherit (self) lib;
    inherit (self.pkgs)
      glibc fetchFromGitLab makeWrapper buildGoPackage
      linkFarm writeShellScript
      libnvidia-container;

    containerRuntimePath = "runc";
    configTemplate = ./config.toml;
  };

  nvidia-k3s = self.pkgs.symlinkJoin {
    name = "nvidia-k3s";
    paths = [
      self.libnvidia-container
      self.nvidia-container-toolkit
    ];
  };
}
