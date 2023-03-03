{
  imports = [
    ./kables-hardware.nix
    ../server.nix
  ];

  networking.hostName = "kables";

  # static local ip assumed by extraHosts for server lookup by other nodes
  networking.interfaces.wlp4s0.ipv4.addresses = [{
  	address = "192.168.1.69";
	prefixLength = 24;
  }];

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
