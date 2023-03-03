{ config, pkgs, lib, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
  	enable = true;
	settings = {
		PermitRootLogin = "no";
		PasswordAuthentication = lib.mkDefault false;
	};
	#kdbInteractiveAuthentication = false;
  };
}
