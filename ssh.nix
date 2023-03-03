{ config, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
  	enable = true;
	settings = {
		PermitRootLogin = "no";
		PasswordAuthentication = false;
	};
	#kdbInteractiveAuthentication = false;
  };
}
