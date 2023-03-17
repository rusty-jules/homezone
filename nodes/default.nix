{ lib, config, ... }:
let
  hostOptions = with lib; {
    ipv4 = mkOption {
      type = types.str;
      description = ''
        				unique ipv4 address
        			'';
    };

    ipv6 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        				unique ipv6 address or none
        			'';
    };

    wifiInterfaceName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        				name of the wifi interface for this device
        			'';
    };
  };
in
{
  options = with lib; {
    networking.homezone.hosts = mkOption {
      type = with types; attrsOf (submodule [{ options = hostOptions; }]);
      description = "A host in the cluster";
    };
    networking.homezone.currentHost = mkOption {
      type = with types; submodule [{ options = hostOptions; }];
      default = config.networking.homezone.hosts.${config.networking.hostName};
      description = "The host that is described by this config";
    };
  };
  config = {
    warnings =
      lib.optional (!(config.networking.homezone.hosts ? ${config.networking.hostName}))
        "no network configuration for ${config.networking.hostName} found in ${./hosts.nix}";

    networking.homezone.hosts = rec {
      kables = {
        ipv4 = "192.168.1.69";
        wifiInterfaceName = "wlp4s0";
      };
      platy = {
        ipv4 = "192.168.1.70";
        ipv6 = "::192.168.1.70";
        wifiInterfaceName = "wlp1s0";
      };
      jables = {
        ipv4 = "192.168.1.71";
        wifiInterfaceName = "wlp2s0";
      };
      lamey = {
        ipv4 = "192.168.1.72";
      };
      "nixery.registries.jables" = {
        ipv4 = jables.ipv4;
      };
    };
  };
}
