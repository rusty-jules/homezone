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
      openssh.authorizedKeys.keys =
        let
          keys = import ../net/keys.nix;
        in
        [ keys.homezone ];
    };
  };

  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = config.networking.homezone.currentHost.etherInterfaceName;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  networking.interfaces.${config.networking.homezone.currentHost.etherInterfaceName}.ipv4.routes = [
    {
      options.scope = "global";
      address = "192.168.1.0";
      prefixLength = 24;
      via = config.networking.homezone.currentHost.etherIp;
    }
  ];

  networking.interfaces.${config.networking.homezone.currentHost.wifiInterfaceName}.ipv4.routes = [
    {
      options.scope = "global";
      # lower the priority of the wifi interface for the 192.168.1.0/24 subnet
      options.metric = "100";
      address = "192.168.1.0";
      prefixLength = 24;
      via = config.networking.homezone.currentHost.etherIp;
    }
    {
      options.scope = "global";
      # lower the priority of the wifi interface for the 192.168.1.0/24 subnet
      options.metric = "100";
      address = "192.168.1.0";
      prefixLength = 24;
      via = config.networking.homezone.currentHost.ipv4;
    }
  ];

  # nix settings, such as virtualization
  boot.binfmt.emulatedSystems = [ "armv7l-linux" ];

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
