{ config, pkgs, lib, ... }:
{
  imports = [
    <nix-bitcoin/modules/presets/secure-node.nix>

    ./base.nix
    ./website
    ./matrix.nix
    ./backup.nix
  ];

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  nix-bitcoin.onionServices.bitcoind.public = true;
  services.bitcoind = {
    i2p = true;
    tor.enforce = false;
    tor.proxy = false;
  };

  services.clightning = {
    enable = true;
    plugins.clboss.enable = true;
    extraConfig = ''
      alias=nixbitcoin.org
    '';
  };
  nix-bitcoin.onionServices.clightning.public = true;
  systemd.services.clightning.serviceConfig.TimeoutStartSec = "5m";

  services.rtl.enable = true;
  services.rtl.nodes.clightning.enable = true;

  services.electrs.enable = true;

  services.btcpayserver = {
    enable = true;
    lightningBackend = "clightning";
    lbtc = true;
  };
  nix-bitcoin.onionServices.btcpayserver.enable = true;

  nix-bitcoin.netns-isolation.enable = true;

  services.joinmarket = {
    enable = true;
    yieldgenerator.enable = true;
  };
  services.joinmarket-ob-watcher.enable = true;

  services.mempool = {
    enable = true;
    electrumServer = "fulcrum";
  };
  services.fulcrum = {
    enable = true;
    port = 50011;
  };

  nix-bitcoin-org.website = {
    enable = true;
    donate.btcpayserverAppId = "3NKhG5wANegkfmXJ5x4ZNuSAB1z5";
  };

  environment.shellAliases = {
    sudo = "doas";
  };

  nix-bitcoin.configVersion = "0.0.70";
}
