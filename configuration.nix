{ config, pkgs, lib, ... }:

{
  imports = [
    ./net
    ./nodes
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

  # increase maximum number of open files
  # https://github.com/NixOS/nixpkgs/issues/159964
  systemd.services."user@1000".serviceConfig.LimitNOFILE = "32768";
  security.pam.loginLimits = [
    {domain = "*"; type = "-"; item = "nofile"; value = "32768";}
  ];

  system.copySystemConfiguration = lib.mkDefault false;

  system.stateVersion = lib.mkDefault "22.11";
}

