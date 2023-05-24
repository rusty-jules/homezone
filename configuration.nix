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
  # etcd recommends 64,000
  boot.kernel.sysctl = {
    "fs.file-max" = 1000000;
    # https://community.harness.io/t/failed-to-create-fsnotify-watcher-too-many-open-files/11945
    "fs.inotify.max_user_watches" = 100000;
    "fs.inotify.max_user_instances" = 100000;
  };
  systemd.services."user@1000".serviceConfig.LimitNOFILE = "524288";
  security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "nofile"; value = "524288"; }
  ];

  system.copySystemConfiguration = lib.mkDefault false;

  system.stateVersion = lib.mkDefault "22.11";
}

