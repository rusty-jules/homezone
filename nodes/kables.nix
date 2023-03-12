{ config, pkgs, ... }:
{
  imports = [
    ./kables-hardware.nix
    ../k3s/agent.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda";
  };

  networking.hostName = "kables";

  users.users.mbp = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];

    createHome = true;
    home = "/home/mbp";
  };

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
