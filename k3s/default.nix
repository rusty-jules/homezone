{ config, pkgs, lib, ... }:

{
	networking = {
		firewall = {
			enable = false;
			allowedTCPPorts = lib.mkDefault [ 6443 ];
		};
	};

	virtualisation = {
		libvirtd.enable = true;
		lxc.enable = true;
	};

	boot.kernel.sysctl."net.ipv6.conf.wlp4s0.accept_ra" = 2;

	security.polkit.enable = true;

	services.k3s.enable = true;

	environment.systemPackages = [ pkgs.k3s pkgs.iptables ];
	systemd.services.k3s.path = [ pkgs.ipset ];
}
