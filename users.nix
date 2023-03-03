{ config, pkgs, ... }:

# Define a user account. Don't forget to set a password with ‘passwd’.
{
  users.users.mbp = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];

    createHome = true;
    home = "/home/mbp";
  };
}
