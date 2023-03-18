{ config, pkgs, ... }:
{
  imports = [ ./base.nix ];

  services.k3s.role = "server";
}
