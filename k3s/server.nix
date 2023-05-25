{ config, pkgs, ... }:
{
  imports = [ ./base.nix ];

  services.k3s = {
    role = "server";
    # This was needed for the initial etcd bootstrap, but subsequent
    # starts of k3s (admittedly after a node crash) did not function
    # with this flag enabled
    #clusterInit = true;

    # we apply this ourselves
    extraFlags = toString [
      "--disable=local-storage"
    ];
  };
}
