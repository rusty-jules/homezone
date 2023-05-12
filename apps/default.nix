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
  ];

  programs = {
    light.enable = true;
  };
}
