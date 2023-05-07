{ config, pkgs, ... }:

{
  imports = [
    ./jables-hardware.nix
    ../k3s/server.nix
    ../net/ssh.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/nvme0n1";
  };

  networking.hostName = "jables";

  users.users.jables = {
    isNormalUser = true;
    initialPassword = "123pw";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];
  };

  services.logind.lidSwitch = "ignore";

  # thunderbolt 3 management
  services.hardware.bolt.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
