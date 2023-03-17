{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    sops
    ssh-to-age
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];
}
