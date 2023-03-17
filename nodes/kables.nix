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

  users.users = {
    mbp = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      createHome = true;
      home = "/home/mbp";
    };
    kables = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      createHome = true;
      home = "/home/kables";
      openssh.authorizedKeys.keys = let
        keys = import ../net/keys.nix;
      in [ keys.homezone ];
    };
  };

  # nix settings, such as virtualization
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ]; 

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
