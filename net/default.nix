{ config, pkgs, lib, ... }:

let
	currentHost = config.networking.homezone.currentHost;
	hosts = config.networking.homezone.hosts;
in
{
	sops.secrets."wifi.env" = { };

  time.timeZone = "America/Los_Angeles";

	networking = {
		hostName = lib.mkDefault "nixos"; # Define your hostname. This should be overridden in nodes/${node}.nix

		firewall.allowedTCPPorts = [ 22 6443 ];

		interfaces.${currentHost.wifiInterfaceName} = {
			ipv4.addresses = [{
				address = currentHost.ipv4;
				prefixLength = 24;
			}];

			ipv6.addresses = lib.mkIf (currentHost.ipv6 != null) [{
				address = currentHost.ipv6;
				prefixLength = 64;
			}];
		};

		wireless = {
			enable = true;  # Enables wireless support via wpa_supplicant.
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

		defaultGateway = "192.168.1.1"; # default route and gateway required by k3s
		nameservers = [ "1.1.1.1" "8.8.8.8" ];

		# "mapAttrsToList" which outputs something like
		# ''
		# 192.168.1.69 kables
		# 192.168.1.70 platy
		# '';
		extraHosts = lib.concatStringsSep "\n" (
			map (name:
				(name: host: "${host.ipv4} ${name}") name hosts.${name}
			) (builtins.attrNames hosts)
		);
	};

	# deeper kube settings
	#networking.dhcpcd.enable = false; # use networkd
	#systemd.network.enable = false;
}
