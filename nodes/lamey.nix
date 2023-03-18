{ config, pkgs, lib, ... }:

{
  imports = [
    ./lamey-hardware.nix
  ];

  boot.loader = {
    grub.enable = false; # uses U-boot configured by the initial image
    generic-extlinux-compatible.enable = true;
  };

  # need to use non-default armv7l cache
  nix.settings = {
    extra-substituters = lib.mkForce [ "https://cache.armv7l.xyz" "ssh://eu.nixbuild.net" ];
    extra-trusted-public-keys = lib.mkForce [
      "cache.armv7l.xyz-1:kBY/eGnBAYiqYfg0fy0inWhshUo+pGFM3Pj7kIkmlBk="
      "nixbuild.net/julianaichholz@gmail.com-1:BcMjG/fFSLmp3KxL+XvQhcHgMDEC3IHnhCv/AHTe9Ao="
    ];
  };

  swapDevices = [
    {
      device = "/.swapfile";
      size = 2048;
    }
  ];

  boot.initrd.includeDefaultModules = false;
  boot.initrd.kernelModules = [ "ext4" "mmc_block" ];

  users.users.pi = {
    isNormalUser = true;
    password = "123pw";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys =
      let
        keys = import ../net/keys.nix;
      in
      [ keys.homezone ];
  };

  networking.hostName = "lamey";
  system.stateVersion = "23.05"; # Did you read the comment?
}
