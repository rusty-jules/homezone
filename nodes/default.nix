{ lib, config, ... }:
let
  hostOptions = with lib; {
    rootGateway = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };

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

    etherIp = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    wifiInterfaceName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        				name of the wifi interface for this device
        			'';
    };

    etherInterfaceName = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    iscsiInitiatorName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        iscsi initiator name generated with iscsi-iname.
        required for each node in the cluster that will
        use longhorn.
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
        etherIp = "192.168.1.169";
        wifiInterfaceName = "wlp4s0";
        etherInterfaceName = "ens9";
        iscsiInitiatorName = "iqn.2016-04.com.open-iscsi:a1d73497bdb4";
      };
      platy = {
        ipv4 = "192.168.1.70";
        etherIp = "192.168.1.170";
        wifiInterfaceName = "wlp1s0";
        etherInterfaceName = "enp0s20u4";
        iscsiInitiatorName = "iqn.2016-04.com.open-iscsi:3df2c416388d";
      };
      jables = {
        ipv4 = "192.168.1.71";
        etherIp = "192.168.1.171";
        wifiInterfaceName = "wlp2s0";
        etherInterfaceName = "enp7s0u1";
        iscsiInitiatorName = "iqn.2016-04.com.open-iscsi:9a15bf737f1";
      };
      ljesus = {
        ipv4 = "10.0.0.72";
        etherIp = "192.168.1.172";
        wifiInterfaceName = "wlp4s0";
        etherInterfaceName = "ens9";
        iscsiInitiatorName = "iqn-2016-04.com.open-iscsi:a034333aa5";
      };
      belakay = {
        ipv4 = "192.168.1.73";
        etherIp = "192.168.1.173";
        wifiInterfaceName = "wlp0s20f0u2";
        etherInterfaceName = "enp0s31f6";
        iscsiInitiatorName = "iqn-2016-04.com.open-iscsi:73b4c20e59";
      };
      lamey = {
        ipv4 = "192.168.1.80";
      };
      "nixery.registries.jables" = {
        ipv4 = jables.ipv4;
        etherIp = jables.etherIp;
      };
      "zot.registry.jables" = {
        ipv4 = jables.ipv4;
        etherIp = jables.etherIp;
      };
    };
  };
}
