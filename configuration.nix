flakeInputs:

{ config, pkgs, lib, ... }:
{
  imports = [
    flakeInputs.nix-bitcoin.nixosModules.default
    (flakeInputs.nix-bitcoin + "/modules/presets/secure-node.nix")
    flakeInputs.nix-bitcoin-mempool.nixosModules.default
    flakeInputs.nixos-mailserver.outPath

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
    extraConfig = ''
      mempoolfullrbf=1
    '';
  };

  services.clightning = {
    enable = true;
    tor.enforce = false;
    tor.proxy = false;
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

  services.fulcrum = {
    enable = true;
    port = 50011;
  };

  services.mempool = {
    enable = true;
    electrumServer = "fulcrum";
    tor = {
      proxy = true;
      enforce = true;
    };
  };
  nix-bitcoin.onionServices.mempool-frontend.enable = true;

  nixbitcoin-org.website = {
    enable = true;
    donate.btcpayserverAppId = "3NKhG5wANegkfmXJ5x4ZNuSAB1z5";
  };

  programs.extra-container.enable = true;

  environment.shellAliases = {
    sudo = "doas";
  };
  environment.variables = {
    # Use 24h time format
    LC_TIME = "C.UTF-8";
  };

  nix-bitcoin.configVersion = "0.0.85";
}
