{ config, ... }:

{
  # Keep tmux alive
  services.logind.extraConfig = ''
    KillUserProcesses=no
  '';
}
