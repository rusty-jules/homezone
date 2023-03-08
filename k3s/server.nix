{ config, pkgs, ... }:
{
	#"--node-ip ${config.networking.homezone.currentHost.ipv4}"
	services.k3s = {
		role = "server";
		#serverAddr = "https://${config.networking.homezone.currentHost.ipv4}:6443";
		#extraFlags = toString [
		#	"--write-kubeconfig-mode"
		#];
	};
}
