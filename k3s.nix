{ config, pkgs, lib, ... }:

{
	imports = [
	  ./encryption.nix
	];

	networking.firewall.allowedTCPPorts = lib.mkDefault [ 6443 ];

	boot.kernel.sysctl."net.ipv6.conf.wlp4s0.accept_ra" = 2;

	security.polkit.enable = true;
	virtualisation.libvirtd.enable = true;
	virtualisation.lxc.enable = true;

	services.k3s.enable = true;
		#enable = true;
		#extraFlags = lib.mkDefault toString [
		#	#"--container-runtime-endpoint unix:///run/containerd/containerd.sock"
		#	"--write-kubeconfig-mode"
		#	#"--cluster-cidr 10.42.0.0/16,fd42::/60"
		#	#"--service-cidr 10.43.0.0/16,fd43::/112"
		#	"--flannel-ipv6-masq"
		#];

	networking.firewall.enable = false;
	environment.systemPackages = [ pkgs.k3s pkgs.iptables ];
	systemd.services.k3s.path = [ pkgs.ipset ];

	#virtualisation.containerd.enable = true;

	#systemd.services.k3s = {
	#	wants = [ "containerd.service" ];
	#	after = [ "containerd.service" ];
	#};

}
