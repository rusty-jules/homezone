{ config, pkgs, lib, ... }:

{
  imports = [
    ./platy-hardware.nix
    ../k3s/agent.nix
  ];

  # Use the GRUB 2 boot loader.
	boot.loader.grub = {
		enable = true;
		version = 2;
		# Define on which hard drive you want to install Grub.
		device = "/dev/sda";
	};

  users.users.platy = {
    isNormalUser = true;
    initialPassword = "123pw";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

	networking.hostName = "platy";

	systemd.sleep.extraConfig = lib.concatStringsSep "\n" [
		"AllowHibernation=no"
		"AllowHybridSleep=no"
		"AllowSuspendThenHibernate=no"
	];

	services = {
		xserver.libinput.enable = true;
		logind.lidSwitch = "ignore";
		logind.lidSwitchDocked = "ignore";
		logind.lidSwitchExternalPower = "ignore";
		upower.ignoreLid = true;

		openssh.enable = true;
	};

	system = {
		copySystemConfiguration = false;
		stateVersion = "22.11";
	};
}
