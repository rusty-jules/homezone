{ pkgs, lib, ... }:

{
  imports = [
    ./encryption.nix
    ./tmux.nix
    ./zsh.nix
    ./bash.nix
    ./neovim.nix
    ./mosh.nix
  ];

  environment.systemPackages = with pkgs; [
    zsh
    tmux
    vim
    wget
    curl
    git
    nushell
    jq
    pciutils
  ] ++ lib.optionals (pkgs.system != "armv7l-linux") [
    fd
    sd
    ripgrep
    bat
    bottom
    du-dust
    exa
    # apps required for additional k3s services
    # for longhorn
    nfs-utils
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#id6
    # https://itnext.io/enabling-nvidia-gpus-on-k3s-for-cuda-workloads-a11b96f967b0
    nvidia-container-toolkit
  ];

  programs = {
    light.enable = true;
  };
}
