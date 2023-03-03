{ config, pkgs, lib, ... }:

{
	environment.systemPackages = with pkgs; [
		age
		sops
	];

	nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
	  "1password-cli"
	];
}
