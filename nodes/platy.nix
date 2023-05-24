{ config, pkgs, lib, ... }:

let
  currentHost = config.networking.homezone.currentHost;
in
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
    interface = currentHost.etherInterfaceName;
  };

  networking.interfaces.${currentHost.etherInterfaceName}.ipv4.routes = [
    {
      options.scope = "global";
      address = "192.168.1.0";
      prefixLength = 24;
      via = currentHost.etherIp;
    }
  ];

  networking.interfaces.${currentHost.wifiInterfaceName}.ipv4.routes = [
    {
      options.scope = "global";
      # lower the priority of the wifi interface for the 192.168.1.0/24 subnet
      options.metric = "100";
      address = "192.168.1.0";
      prefixLength = 24;
      via = currentHost.etherIp;
    }
    {
      options.scope = "global";
      # lower the priority of the wifi interface for the 192.168.1.0/24 subnet
      options.metric = "100";
      address = "192.168.1.0";
      prefixLength = 24;
      via = currentHost.ipv4;
    }
  ];

  systemd.services.platy-eth-network-mon =
  # script to restart the eth network interface if it goes down.
  # this is a platy-only issue with the eth adapter I guess.
  let
    restartEth = pkgs.writeScript "restart-eth.sh" ''
      #!${pkgs.stdenv.shell}

      RESTART_FILE="/etc/last-eth-restart"
      MINIMUM_RESTART_INTERVAL=300
      CHECK_INTERVAL=5

      while true; do
        ${pkgs.iputils}/bin/ping -c 1 belakay > /dev/null

        if [ $? -ne 0 ]; then
          # check it again
          ${pkgs.iputils}/bin/ping -c 1 belakay > /dev/null

          if [ $? -ne 0 ]; then
            CURRENT_TIME=$(date +%s)
            LAST_RESTART_TIME=$(cat $RESTART_FILE 2>/dev/null || echo 0)
            TIME_SINCE_LAST_RESTART=$((CURRENT_TIME - LAST_RESTART_TIME))

            if [ $TIME_SINCE_LAST_RESTART -ge $MINIMUM_RESTART_INTERVAL ]; then
              echo "Network connection to belakay failed. Restarting ${currentHost.etherInterfaceName}"
              ${pkgs.iproute2}/bin/ip link set ${currentHost.etherInterfaceName} down
              ${pkgs.iproute2}/bin/ip link set ${currentHost.etherInterfaceName} up
            else
              echo "Network connection failed but the last restart was less than 5 minutes ago. Skipping restart..."
            fi
          fi
        fi

        sleep $CHECK_INTERVAL
      done
    '';
  in
  lib.mkDefault {
    description = "Restart Ethernet";
    script = "${restartEth}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = lib.mkDefault "${restartEth}";
      User = "root";
      Restart = "always";
    };
  };

  system = {
    copySystemConfiguration = false;
    stateVersion = "22.11";
  };
}
