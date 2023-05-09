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
in
{
  nvidia-container-toolkit = super.stdenv.mkDerivation {
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
    ];

    runtimeDependencies = with super.pkgs; [
      # I have no idea which "linux_{flavor}" applies since the installed version
      # was "selected" by services.xerver.videoDrivers, but I assume it needs to
      # match the version of linux installed...selecting that will make this able
      # to actually be added to upstream
      linuxKernel.packages.linux_5_15.nvidia_x11_production
      cudaPackages.cuda_nvml_dev
    ];

    prePatch = ''
      substituteInPlace Makefile --replace \
      "/usr/local" \
      $out/usr/local
    '';

    patches = [ ./remove-curls.patch ];

    buildPhase = ''
      export GOCACHE=$NIX_BUILD_TOP/.cache
      export GOPATH=$NIX_BUILD_TOP/go
      make
    '';

    dontStrip = true;

    installPhase = ''
      # ensure we do not use bmake, which was required for elftoolchain,
      # but is not compatible with the root Makefile
      make install prefix=$out exec_prefix=$out
    '';
  };
}
