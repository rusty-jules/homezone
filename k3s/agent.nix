{ config, pkgs, lib, ... }:
{
  imports = [ ./base.nix ];
  sops.secrets.k3s_node_token2 = { };
  services.k3s = {
    role = "agent";
    tokenFile = lib.mkDefault config.sops.secrets.k3s_node_token2.path;
    serverAddr = lib.mkDefault "https://belakay:6443";
    extraFlags = toString [
      "--node-ip ${config.networking.homezone.currentHost.ipv4}"
    ];
  };
}
