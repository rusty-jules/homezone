{ config, pkgs, lib, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
  	enable = true;
	settings = {
		PermitRootLogin = "no";
		PasswordAuthentication = lib.mkDefault false;
	};
	#kdbInteractiveAuthentication = false;
  };

  programs.ssh = {
    #knownHosts.platy = {
    #  hostNames = [ "platy" ];
    #  publicKey = "";
    #};
    knownHosts.jables = {
      hostNames = [ "jables" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIfEIpmNYvgYq5o5gQaHyUbt2ajhBOWaxxZkU5+0Y3R";
    };
    knownHosts.github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    knownHosts.homeZone = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBhGVjzjavCel13AhBErB6wj3F6fbtpwqBfhWw2WnJ6";
    };
    extraConfig = ''
      Host platy
        HostName platy
        User platy
        IdentitiesOnly yes
        IdentityFile /etc/ssh/id_ed25519_homezone
      Host jables
        HostName jables
        User platy
        IdentitiesOnly yes
        IdentityFile /etc/ssh/id_ed25519_homezone
      Host github
        HostName github.com
        User git
        IdentitiesOnly yes
        IdentityFile /etc/ssh/id_ed25519_homezone
    '';
  };

  nix.buildMachines = [
    {
      hostName = "platy";
      system = "x86_64-linux";
      maxJobs = 10;
      speedFactor = 30; # cachix defaults to 40, so higher priority
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
  ];

  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
    secret-key-files = /root/cache-priv-key.pem
  '';

  nix.settings = {
    trusted-users = lib.attrNames config.networking.homezone.hosts;
    trusted-substituters = lib.attrNames config.networking.homezone.hosts;
    extra-trusted-public-keys = ''
      jables:oEzej0jJeG5bSVEmgYxmqmBYN/oiEQG4ng8xKaYCluM=
    '';
  };
   
}
