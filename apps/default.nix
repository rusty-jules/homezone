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
  ] ++ lib.optionals (pkgs.system != "armv7l-linux") [
    fd
    sd
    ripgrep
    bat
    bottom
    dust
  ];

  programs = {
    light.enable = true;
  };
}
