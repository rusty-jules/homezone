{ config, pkgs, lib, ... }:

{
  imports = [
    ./platy-hardware.nix
    ../k3s/ha-server.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    # Define on which hard drive you want to install Grub.
    device = "/dev/sda";
  };

  users.users.platy = {
    isNormalUser = true;
    initialPassword = "123pw";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  networking.hostName = "platy";

  systemd.sleep.extraConfig = lib.concatStringsSep "\n" [
    "AllowHibernation=no"
    "AllowHybridSleep=no"
    "AllowSuspendThenHibernate=no"
  ];

  services = {
    xserver.libinput.enable = true;
    logind.lidSwitch = "ignore";
    logind.lidSwitchDocked = "ignore";
    logind.lidSwitchExternalPower = "ignore";
    upower.ignoreLid = true;
  };

  networking.defaultGateway = {
    address = "192.168.1.1";
    interface = config.networking.homezone.currentHost.etherInterfaceName;
  };

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

  system = {
    copySystemConfiguration = false;
    stateVersion = "22.11";
  };
}
