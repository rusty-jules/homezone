{ config, pkgs, ... }:

let
  keys = import ../net/keys.nix;
in
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
      openssh.authorizedKeys.keys = [ keys.homezone ];
  	};
    root.openssh.authorizedKeys.keys = [ keys.homezone ];
	};

  # Authorize thunderbolt devices whenever they are plugged in witha udev rule
  # https://discourse.nixos.org/t/thunderbolt-acl/2475
  # Also nixpkgs#thunderbolt gives tbtadm which lists devices.
  # Could potentially add specific devices to ACL
  # https://christian.kellner.me/2019/02/11/thunderbolt-preboot-access-control-list-support-in-bolt/
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
