{ pkgs, lib, ... }:

{
  imports = [
    ./encryption.nix
    ./tmux.nix
    ./zsh.nix
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
    # apps required for additional k3s services
    # for longhorn
    openiscsi
  ] ++ lib.optionals (pkgs.system != "armv7l-linux") [
    fd
    sd
    ripgrep
    bat
    bottom
    du-dust
  ];

  programs = {
    light.enable = true;
  };
}
