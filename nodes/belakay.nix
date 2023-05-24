{ config, pkgs, ... }:

let
  keys = import ../net/keys.nix;
  currentHost = config.networking.homezone.currentHost;
in
{
  imports = [
    ./belakay-hardware.nix
    ../k3s/ha-server.nix
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

  # This selects the Nvidia Driver version, GTX 1070 is not yet legacy!
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  networking = {
    defaultGateway = {
      address = "192.168.1.1";
      interface = currentHost.wifiInterfaceName;
    };
    interfaces = {
      ${currentHost.etherInterfaceName}.ipv4.routes = [{
        options.scope = "global";
        address = "192.168.1.0";
        prefixLength = 24;
        via = currentHost.etherIp;
      }];
      ${currentHost.wifiInterfaceName}.ipv4.routes = [{
        options.scope = "global";
        options.metric = "100";
        address = "192.168.1.0";
        prefixLength = 24;
        via = currentHost.ipv4;
      }];
    };
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
