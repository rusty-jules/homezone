self: super:
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

    nativeBuildInputs = with super.pkgs; [
      git
    ];

    patchPhase = ''
      substituteInPlace Makefile --replace \
      "/usr/local" \
      $out/usr/local
    '';
  };
}
