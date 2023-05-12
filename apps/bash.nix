{ pkgs, ... }:
{
  environment.interactiveShellInit = ''
      alias ll="exa --tree --color=always -L 3"
    '';
}
