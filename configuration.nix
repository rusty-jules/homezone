{ config, pkgs, lib, ... }:

{
  imports = [
    ./net
    ./nodes
    ./k3s
    ./apps
    ./customization
  ];

  # Enable Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  sops = {
    defaultSopsFile = ./secrets.enc.yml;
  };

  system.copySystemConfiguration = lib.mkDefault false;

  system.stateVersion = lib.mkDefault "22.11";
}

