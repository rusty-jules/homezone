{ config, pkgs, lib, ... }:
{
  imports = [ ./base.nix ];
  sops.secrets.k3s_node_token2 = { };
  services.k3s = {
    role = "server";
    tokenFile = lib.mkDefault config.sops.secrets.k3s_node_token2.path;
    serverAddr = lib.mkDefault "https://192.168.1.73:6443";
    extraFlags = toString [
      "--node-ip ${config.networking.homezone.currentHost.ipv4}"
    ];
  };
}
