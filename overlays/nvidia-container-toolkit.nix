{ lib
, addOpenGLRunpath
, glibc
, fetchFromGitLab
, makeWrapper
, buildGoPackage
, linkFarm
, writeShellScript
, containerRuntimePath
, configTemplate
, libnvidia-container
, unpatched-nvidia-driver
}:
let
  isolatedContainerRuntimePath = linkFarm "isolated_container_runtime_path" [
    {
      name = "runc";
      path = containerRuntimePath;
    }
  ];
  warnIfXdgConfigHomeIsSet = writeShellScript "warn_if_xdg_config_home_is_set" ''
    set -eo pipefail

    if [ -n "$XDG_CONFIG_HOME" ]; then
      echo >&2 "$(tput setaf 3)warning: \$XDG_CONFIG_HOME=$XDG_CONFIG_HOME$(tput sgr 0)"
    fi
  '';
in
buildGoPackage rec {
  pname = "container-toolkit/container-toolkit";
  version = "1.13.1";

  src = fetchFromGitLab {
    owner = "nvidia";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-RPH353pnGHBvbunFgiiPgQIfeXKLCkIIO2Cz6+Qp8AU=";
  };

  goPackagePath = "github.com/NVIDIA/nvidia-container-toolkit";

  ldflags = [ "-s" "-w" ];

  nativeBuildInputs = [ makeWrapper ];

  preBuild = ''
    # replace the default hookDefaultFilePath to the $out path
    # substituteInPlace go/src/github.com/NVIDIA/nvidia-container-toolkit/cmd/nvidia-container-runtime/main.go \
    #   --replace '/usr/bin/nvidia-container-runtime-hook' '${placeholder "out"}/bin/nvidia-container-runtime-hook'

    # JA: Changed (paths moved in new version)
    substituteInPlace go/src/github.com/NVIDIA/nvidia-container-toolkit/internal/config/config.go \
      --replace '/usr/bin' '${placeholder "out"}/bin'

    sed -i -e "s@/etc/ld.so.cache@/tmp/ld.so.cache@" -e "s@/etc/ld.so.conf@/tmp/ld.so.conf@" \
      go/src/github.com/NVIDIA/nvidia-container-toolkit/internal/ldcache/ldcache.go \
      go/src/github.com/NVIDIA/nvidia-container-toolkit/cmd/nvidia-ctk/hook/update-ldcache/update-ldcache.go \

    sed -i "s@/usr/lib/x86_64-linux-gnu@${unpatched-nvidia-driver}/lib@" \
      go/src/github.com/NVIDIA/nvidia-container-toolkit/internal/discover/graphics.go

    # add nvidia-driver to the cuda lib search path
    sed -i '/WithSearchPaths(/a \\t\t"/${unpatched-nvidia-driver}/lib",' go/src/github.com/NVIDIA/nvidia-container-toolkit/internal/lookup/cuda/cuda.go
  '';

  postInstall =
  let
    inherit (addOpenGLRunpath) driverLink;
    libraryPath = lib.makeLibraryPath [ "$out" driverLink "${driverLink}-32" ];
  in
  ''
    mkdir -p $out/etc/nvidia-container-runtime

    # nvidia-container-runtime invokes docker-runc or runc if that isn't
    # available on PATH.
    #
    # Also set XDG_CONFIG_HOME if it isn't already to allow overriding
    # configuration. This in turn allows users to have the nvidia container
    # runtime enabled for any number of higher level runtimes like docker and
    # podman, i.e., there's no need to have mutually exclusivity on what high
    # level runtime can enable the nvidia runtime because each high level
    # runtime has its own config.toml file.
    wrapProgram $out/bin/nvidia-container-runtime \
      --run "${warnIfXdgConfigHomeIsSet}" \
      --prefix LD_LIBRARY_PATH : ${libraryPath} \
      --prefix PATH : ${isolatedContainerRuntimePath}:${libnvidia-container}/bin \
      --set-default XDG_CONFIG_HOME $out/etc

    cp ${configTemplate} $out/etc/nvidia-container-runtime/config.toml

    substituteInPlace $out/etc/nvidia-container-runtime/config.toml \
      --subst-var-by glibcbin ${lib.getBin glibc}

    # ln -s $out/bin/nvidia-container-{toolkit,runtime-hook}

    # wrapProgram $out/bin/nvidia-container-toolkit \
    # JA: Changed, the above binary doesn't exist
    wrapProgram $out/bin/nvidia-container-runtime-hook \
      --add-flags "-config ${placeholder "out"}/etc/nvidia-container-runtime/config.toml"
  '';

  meta = with lib; {
    homepage = "https://gitlab.com/nvidia/container-toolkit/container-toolkit";
    description = "NVIDIA Container Toolkit";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ cpcloud ];
  };
}
