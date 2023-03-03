{ config, ... }:

{
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "us"; # triggered an error
    useXkbConfig = true;
  };
}
