{ config, pkgs, lib, ... }:

let
  currentHost = config.networking.homezone.currentHost;
  hosts = config.networking.homezone.hosts;
in
{
  imports = [
    ./ssh.nix
  ];

  sops.secrets."wifi.env" = { };

  time.timeZone = "America/Los_Angeles";

  networking = {
    hostName = lib.mkDefault "nixos"; # Define your hostname. This should be overridden in nodes/${node}.nix

    firewall.allowedTCPPorts = [ 22 6443 80 443 2379 2380 ];

    interfaces = {
      ${currentHost.wifiInterfaceName} = lib.mkIf (currentHost.wifiInterfaceName != null) {
        ipv4.addresses = [{
          address = currentHost.ipv4;
          prefixLength = 24;
        }];

        ipv6.addresses = lib.mkIf (currentHost.ipv6 != null) [{
          address = currentHost.ipv6;
          prefixLength = 64;
        }];
      };

      ${currentHost.etherInterfaceName} = lib.mkIf (currentHost.etherInterfaceName != null) {
        ipv4.addresses = lib.mkIf (currentHost.etherIp != null) [{
          address = currentHost.etherIp;
          prefixLength = 24;
        }];
      };
    };

    wireless = {
      enable = pkgs.system != "armv7l-linux"; # Enables wireless support via wpa_supplicant.
      userControlled.enable = true;
      environmentFile = config.sops.secrets."wifi.env".path;
      networks = {
        "@wifi1_ssid@" = {
          psk = "@wifi1_psk@";
        };
        "@wifi2_ssid@" = {
          psk = "@wifi2_psk@";
        };
        "@wifi3_ssid@" = {
          psk = "@wifi3_psk@";
        };
      };
    };

    defaultGateway = {
      address = lib.mkDefault "192.168.1.254"; # default route and gateway required by k3s
      interface = lib.mkDefault config.networking.homezone.currentHost.etherInterfaceName;
    };

    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # "mapAttrsToList" which outputs something like
    # ''
    # 192.168.1.69 kables
    # 192.168.1.70 platy
    # '';
    extraHosts = lib.concatStringsSep "\n" (
      map
        (name:
          (name: host: ''
            ${lib.optionalString (host.etherIp != null) "${host.etherIp} ${name}"} # set ethernet address
            #${lib.optionalString (name == "ljesus") "${host.etherIp} ${name}"} # ljesus needs etherIp to be primary
            #${host.ipv4} ${name} # wifi ip
            ${lib.optionalString (host.ipv6 != null) "${host.ipv6} ${name}"}
          '') name
            hosts.${name}
        )
        (builtins.attrNames hosts)
    );
  };

  # deeper kube settings
  #networking.dhcpcd.enable = false; # use networkd
  #systemd.network.enable = false;
}
