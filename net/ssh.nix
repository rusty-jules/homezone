{ config, pkgs, lib, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  programs.ssh = {
    startAgent = true;
    knownHosts.platy = {
      hostNames = [ "platy" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQSWarpYNzA7f02cav7MNtpPN4y8QZJINXhiqef2C7u";
    };
    knownHosts.jables = {
      hostNames = [ "jables" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIfEIpmNYvgYq5o5gQaHyUbt2ajhBOWaxxZkU5+0Y3R";
    };
    knownHosts.kables = {
      hostNames = [ "kables" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN06LyYzBNKJ4w/rtdFliB/7CSoaBZtZJd6LwviDIpa/";
    };
    knownHosts.github = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
    knownHosts.homeZone = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBhGVjzjavCel13AhBErB6wj3F6fbtpwqBfhWw2WnJ6";
    };
    knownHosts.nixBuilds = {
      hostNames = [ "eu.nixbuild.net" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
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
      Host kables
        HostName kables
        User kables
        IdentitiesOnly yes
        IdentityFile /etc/ssh/id_ed25519_homezone
      Host github
        HostName github.com
        User git
        IdentitiesOnly yes
        IdentityFile /etc/ssh/id_ed25519_homezone
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        IdentityFile /home/pi/.ssh/id_ed25519_nixbuild
    '';
  };

  nix.buildMachines = builtins.filter (host: host.hostName != config.networking.hostName) [
    {
      hostName = "jables";
      system = "x86_64-linux";
      maxJobs = 2;
      speedFactor = 15; # cachix defaults to 40, so higher priority
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "platy";
      system = "x86_64-linux";
      maxJobs = 4;
      speedFactor = 25;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "kables";
      system = "x86_64-linux";
      maxJobs = 8;
      speedFactor = 35;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    }
    {
      hostName = "eu.nixbuild.net";
      system = "armv7l-linux";
      maxJobs = 100;
      speedFactor = 35;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    }
  ];

  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
    secret-key-files = /root/cache-priv-key.pem
  '';

  nix.settings = {
    trusted-users = lib.attrNames config.networking.homezone.hosts;
    substituters = lib.attrNames config.networking.homezone.hosts;
    extra-trusted-public-keys = lib.concatStringsSep " " [
      "jables:oEzej0jJeG5bSVEmgYxmqmBYN/oiEQG4ng8xKaYCluM="
      "platy:k6u4eQnT9RYVsMTYnwkhbbypta6okLp1wwpk8q90TLA="
      "kables:8u1N3KEwmzzVUyaknzjW3G1fjjcU3XQw5Ocj1S2Thlg="
      "nixbuild.net/julianaichholz@gmail.com-1:BcMjG/fFSLmp3KxL+XvQhcHgMDEC3IHnhCv/AHTe9Ao="
    ];
  };

}
