{ config, pkgs, ... }:

let
  keys = import ../net/keys.nix;
in
{
  imports = [
    ./ljesus-hardware.nix
    ../k3s/agent.nix
    ../apps/cuda.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.hostName = "ljesus";

  users.users = {
    ljesus = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      createHome = true;
      home = "/home/ljesus";
      openssh.authorizedKeys.keys = [ keys.homezone ];
    };
    root.openssh.authorizedKeys.keys = [ keys.homezone ];
  };

  # Authorize thunderbolt devices whenever they are plugged in witha udev rule
  # https://discourse.nixos.org/t/thunderbolt-acl/2475
  # Also nixpkgs#thunderbolt gives tbtadm which lists devices.
  # Could potentially add specific devices to ACL
  # https://christian.kellner.me/2019/02/11/thunderbolt-preboot-access-control-list-support-in-bolt/
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';

  # Nvidia Hardware
  # https://dataswamp.org/~solene/2021-12-05-nixos-egpu.html#_NixOS
  # https://nixos.wiki/wiki/Nvidia
  #hardware.nvidia = {
  #  modesetting.enable = true;
  #  prime = {
  #    offload.enable = true;
  #    allowExternalGpu = true;
  #    # discovered with lspci + hex->decimal conversion
  #    nvidiaBusId = "PCI:62:0:0"; # 3e:00.0
  #    intelBusId = "PCI:0:2:0"; # 00:02.0
  #  };
  #};

  services.logind.lidSwitch = "ignore";

  system.copySystemConfiguration = false;
  system.stateVersion = "22.11";
}
