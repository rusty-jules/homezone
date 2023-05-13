{ config, pkgs, ... }:

let
  keys = import ../net/keys.nix;
in
{
  imports = [
    ./belakay-hardware.nix
    ../k3s/server.nix
    ../apps/cuda.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "belakay";

  users.users = {
    belakay = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      createHome = true;
      home = "/home/belakay";
      openssh.authorizedKeys.keys = [ keys.homezone ];
    };
    root.openssh.authorizedKeys.keys = [ keys.homezone ];
  };

  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = config.networking.homezone.currentHost.etherInterfaceName; 
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
