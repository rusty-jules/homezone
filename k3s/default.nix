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

  # write a k3s registries config file
  environment.etc = {
    "rancher/k3s/registries.yaml" = {
      source = ./registries.yaml;
      mode = "0600";
    };
  };
}
