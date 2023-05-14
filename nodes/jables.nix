{ config, pkgs, lib, ... }:

{
  imports = [
    ./jables-hardware.nix
    ../k3s/ha-server.nix
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

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = config.networking.homezone.currentHost.etherInterfaceName;
    };

    interfaces = {
      "enp7s0u1u4" = {
        ipv4.addresses = lib.mkIf (config.networking.homezone.currentHost.etherIp != null) [{
          address = config.networking.homezone.currentHost.etherIp;
          prefixLength = 24;
        }];
      };

      ${config.networking.homezone.currentHost.etherInterfaceName}.ipv4.routes = [
        {
          options.scope = "global";
          address = "192.168.1.0";
          prefixLength = 24;
          via = config.networking.homezone.currentHost.etherIp;
        }
      ];

      ${config.networking.homezone.currentHost.wifiInterfaceName}.ipv4.routes = map
        (via: {
          options.scope = "global";
          # lower the priority of the wifi interface for the 192.168.1.0/24 subnet
          options.metric = "100";
          address = "192.168.1.0";
          prefixLength = 24;
          via = via;
        }) with config.networking.homezone.currentHost;
      [ etherIp ipv4 ] ++ [ "0.0.0.0" ];
    };
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
