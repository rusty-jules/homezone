self: super:
let
  nvidia-modprobe-version = "495.44";
  nvidia-modprobe-src = super.fetchurl {
    url = "https://github.com/NVIDIA/nvidia-modprobe/archive/${nvidia-modprobe-version}.tar.gz";
    sha256 = "sha256-rm6cfmtDNolFwo9ri20NfMNu5+G+iVWgCaHLGJ5G3pI=";
  };

  elftoolchain-version = "elftoolchain-0.7.1";
  elftoolchain-src = super.fetchurl {
    url = "https://sourceforge.net/projects/elftoolchain/files/Sources/${elftoolchain-version}/${elftoolchain-version}.tar.bz2";
    sha256 = "1dfj5fxvlsqa88rcyxpl88pyqjzvydi7bp8mf8w984pjzj8lbwa4";
  };

  unpatched-nvidia-driver = (self.pkgs.linuxKernel.packages.linux_5_15.nvidia_x11_production.overrideAttrs (oldAttrs: {
    builder = ../overlays/nvidia-builder.sh;
  }));
in
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

  nvidia-container-runtime = super.stdenv.mkDerivation rec {
    pname = "nvidia-container-runtime";
    version = "1.13.1";

    src = super.fetchgit {
      url = "https://gitlab.com/nvidia/container-toolkit/container-toolkit";
      rev = "refs/tags/v1.13.1";
      sha256 = "sha256-4Fya06FMrcX3v0JV+Ab8L/w3SgKLRxtThTEtWUGxR0w=";
    };

    nativeBuildInputs = with super.pkgs; [
      stdenv
      go
    ];

    runtimeDependencies = with self.pkgs; [
      # dynamic lib load of libnvidia-ml.so.1 and libcuda.so.1
      #linuxKernel.packages.linux_5_15.nvidia_x11_production
      unpatched-nvidia-driver
      nvidia-container-toolkit
    ];

    prePatch = ''
      substituteInPlace internal/ldcache/ldcache.go \
        --replace "/etc/ld.so.cache" "/tmp/ld.so.cache"
      substituteInPlace cmd/nvidia-ctk/hook/update-ldcache/update-ldcache.go \
        --replace "/etc/ld.so" "/tmp/ld.so"
      substituteInPlace tools/container/toolkit/toolkit.go \
        --replace "/usr/bin/" "$out/bin/"
    '';

    buildPhase = ''
      export GOCACHE=$NIX_BUILD_TOP/.cache
      export GOPATH=$NIX_BUILD_TOP/go
      make binaries
    '';

    oci-nvidia-hook = ''
      #!/bin/sh
      PATH="${self.lib.concatStringsSep "/bin:" runtimeDependencies}/bin:$out/bin:/run/current-system/sw/bin" \
        $out/bin/nvidia-container-runtime-hook "$@"
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv nvidia-container-runtime* $out/bin
      echo '${oci-nvidia-hook}' > $out/bin/oci-nvidia-hook
      chmod +x $out/bin/oci-nvidia-hook
      substituteInPlace $out/bin/oci-nvidia-hook --replace "\$out" $out
    '';
  };

  nvidia-container-toolkit = super.stdenv.mkDerivation rec {
    pname = "nvidia-container-toolkit";
    version = "1.13.1";

    src = super.fetchgit {
      url = "https://github.com/NVIDIA/libnvidia-container";
      rev = "refs/tags/v1.13.1";
      sha256 = "sha256-QBV0l/pvBSex5IHS9duVPyLW9l27IhyGQysd1b5SpWQ=";
      leaveDotGit = true;
    };

    preConfigure = ''
      # add libtirpc to gcc
      export CFLAGS="-I${super.lib.getDev super.pkgs.libtirpc}/include/tirpc $CFLAGS"
      export LDFLAGS="-L${super.lib.getLib super.pkgs.libtirpc}/lib -ltirpc $LDFLAGS"
    '';

    postUnpack = ''
      mkdir -p $sourceRoot/deps/src/nvidia-modprobe-${nvidia-modprobe-version}
      cat ${nvidia-modprobe-src} | tar -C $sourceRoot/deps/src/nvidia-modprobe-${nvidia-modprobe-version} \
        --strip-components=1 -xz nvidia-modprobe-${nvidia-modprobe-version}/modprobe-utils
      mkdir -p $sourceRoot/deps/src/${elftoolchain-version}
      cat ${elftoolchain-src} | tar -C $sourceRoot/deps/src/${elftoolchain-version}/ \
        --strip-components=1 -xj ${toString (map(dir: "${elftoolchain-version}/${dir}") ["mk" "common" "libelf"])}
    '';

    buildInputs = with super.pkgs; [
      libcap
      libseccomp
      # there is a mk/libtirpc.mk that downloads and builds the source,
      # but it was not run by default `make` for some reason, likely the WITH_TIRPC flag
      libtirpc
    ];

    nativeBuildInputs = with super.pkgs; [
      autoPatchelfHook
      bmake
      gnum4
      git
      go
      lsb-release
      pkg-config
      rpcsvc-proto
      stdenv
      which
      removeReferencesTo
      makeWrapper
    ];

    runtimeDependencies = with self.pkgs; [
      # I have no idea which "linux_{flavor}" applies since the installed version
      # was "selected" by services.xerver.videoDrivers, but I assume it needs to
      # match the version of linux installed...selecting that will make this able
      # to actually be added to upstream
      #linuxKernel.packages.linux_5_15.nvidia_x11_production
      unpatched-nvidia-driver
      # https://github.com/NVIDIA/libnvidia-container/blob/eb0415c458c5e5d97cb8ac08b42803d075ed73cd/src/nvc_info.c#L65
      cudaPackages.fabricmanager
    ];

    enableParallelBuilding = true;

    prePatch = ''
      substituteInPlace src/common.h --replace "/etc/ld.so.cache" "/tmp/ld.so.cache"

      sed -i Makefile \
        -e '/$(INSTALL) -m 755 $(libdir)\/$(LIBGO_SHARED) $(DESTDIR)$(libdir)/d'
    '';

    patches = [ ./remove-curls.patch ./remove-ld-conf.patch ];

    buildPhase = ''
      export GOCACHE=$NIX_BUILD_TOP/.cache
      export GOPATH=$NIX_BUILD_TOP/go
      make prefix=$out/usr/local
    '';

    dontStrip = true;

    installPhase = ''
      # ensure we do not use bmake, which was required for elftoolchain,
      # but is not compatible with the root Makefile
      make install prefix=$out exec_prefix=$out
      runHook postInstall
    '';

    postInstall =
      let
        inherit (super.pkgs.addOpenGLRunpath) driverLink;
        libraryPath = self.lib.makeLibraryPath [ unpatched-nvidia-driver "$out" driverLink "${driverLink}-32" ];
      in
    ''
      remove-references-to -t "${super.pkgs.go}" $out/lib/libnvidia-container-go.so.${version}
      wrapProgram $out/bin/nvidia-container-cli --prefix LD_LIBRARY_PATH : ${libraryPath}
    '';

    #disallowedReferences = [ super.pkgs.go ];
  };
}
