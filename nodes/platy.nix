{ config, pkgs, ... }:
{
  imports = [
    ./platy-hardware.nix
    ../agent.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  services.xserver.libinput.enable = true;
  time.timeZone = "America/Los_Angeles";

  networking.hostName = "platy";

  users.users.platy = {
    isNormalUser = true;
    initialPassword = "123pw";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  networking.interfaces.wlp1s0.ipv4.addresses = [{
  	address = "192.168.1.70";
	prefixLength = 24;
  }];
  networking.interfaces.wlp1s0.ipv6.addresses = [{
	address = "::192.168.1.70";
	prefixLength = 64;
  }];

  networking.firewall.allowedTCPPorts = [ 22 6443 ];


  services.openssh.enable = true;

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
