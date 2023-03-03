{ config, pkgs, lib, ... }:
{
	sops.secrets.k3s_node_token = { };
	services.k3s = {
		role = "agent";
		tokenFile = lib.mkDefault config.sops.secrets.k3s_node_token.path;
		serverAddr = lib.mkDefault "https://kables:6443";
		extraFlags = toString [
			"--node-ip ${config.networking.homezone.currentHost.ipv4}"
		];
	};
}
