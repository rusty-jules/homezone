{ config, pkgs, lib, ... }:

{
  imports = [ 
		./net
		./nodes
		./k3s
		./apps
		./customization
	];

  # Enable Flakes
  nix.settings.experimental-features = [
  	"nix-command"
		"flakes"
  ];

  sops = {
		defaultSopsFile = ./secrets.enc.yml;
  };

  system.copySystemConfiguration = lib.mkDefault true;

  system.stateVersion = "22.11";
}

