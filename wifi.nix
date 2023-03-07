{ config, pkgs, lib, ... }:
{
	sops.secrets."wifi.env" = { };

	networking = {
		hostName = lib.mkDefault "nixos"; # Define your hostname. This should be overridden in nodes/${node}.nix

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

		extraHosts = ''
			192.168.1.69 kables
			192.168.1.70 platy
		'';

	};
	# deeper kube settings
	#networking.dhcpcd.enable = false; # use networkd
	#systemd.network.enable = false;

}
