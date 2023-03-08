{ config, ... }:

{
  services.xserver.xkbOptions = "ctrl:swapcaps";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
}
