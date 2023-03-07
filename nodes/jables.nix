{ config, pkgs, ... }:

{
  imports = [
    ./jables-hardware.nix
    ../agent.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  time.timeZone = "America/Los_Angeles";

  networking.hostName = "jables";

  networking.interfaces.wlp2s0.ipv4.addresses = [{
	address = "192.168.1.71";
	prefixLength = 24;
  }];

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
