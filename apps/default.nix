{ pkgs, ... }:

{
  imports = [
		./encryption.nix
		./tmux.nix
		./zsh.nix
  ];

  environment.systemPackages = with pkgs; [
    zsh
    tmux
    fd
    sd
    ripgrep
    bat
    neovim
    vim
    wget
    curl
    git
  ];
}
