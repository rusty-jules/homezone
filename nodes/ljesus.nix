{ config, pkgs, ... }:
{
  imports = [
    ./ljesus-hardware.nix
    ../k3s/agent.nix
  ];

  boot.loader = {
		systemd-boot.enable = true;
		efi.canTouchEfiVariables = true;
  }; 

	networking.hostName = "ljesus";

	users.users = {
		ljesus = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      createHome = true;
      home = "/home/ljesus";
      openssh.authorizedKeys.keys =
        let
          keys = import ../net/keys.nix;
        in
        [ keys.homezone ];
  	};
	};

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
