{ config, pkgs, ... }:
{
  imports = [
    ./kables-hardware.nix
    ../server.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  networking.hostName = "kables";

  # static local ip assumed by extraHosts for server lookup by other nodes
  networking.interfaces.wlp4s0.ipv4.addresses = [{
  	address = "192.168.1.69";
	prefixLength = 24;
  }];

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
