{ pkgs, ... }:

{
  imports = [
		./encryption.nix
		./tmux.nix
		./zsh.nix
		./neovim.nix
  ];

  environment.systemPackages = with pkgs; [
    zsh
    tmux
    fd
    sd
    ripgrep
    bat
    vim
    wget
    curl
    git
  ];
}
