flakeInputs:

{ config, pkgs, lib, ... }:
{
  imports = [
    flakeInputs.nix-bitcoin.nixosModules.default
    (flakeInputs.nix-bitcoin + "/modules/presets/secure-node.nix")
    flakeInputs.nixos-mailserver.outPath

    ./base.nix
    ./website
    ./matrix.nix
    ./backup.nix
  ];

  # Limit systemd log retention for privacy reasons
  services.journald.extraConfig = ''
    MaxRetentionSec=36h
  '';

  services.bitcoind = {
    i2p = true;
    tor.enforce = false;
    tor.proxy = false;
    rpc.threads = lib.mkForce 20;
    extraConfig = ''
      mempoolfullrbf=1
      rpcworkqueue=32
    '';
  };
  nix-bitcoin.onionServices.bitcoind.public = true;

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

  services.rtl = {
    enable = true;
    nodes.clightning.enable = true;
  };

  services.btcpayserver = {
    enable = true;
    lightningBackend = "clightning";
    lbtc = true;
  };
  nix-bitcoin.onionServices.btcpayserver.enable = true;
  # Don't require `liquidd.service` so that btcp can stay online while liquidd is
  # shutting down/restarting, which can take up to 30 min.
  systemd.services.nbxplorer = rec {
    requires = lib.mkForce [ "bitcoind.service" "postgresql.service" ];
    after = requires;
  };

  services.joinmarket = {
    enable = true;
    yieldgenerator.enable = true;
  };
  services.joinmarket-ob-watcher.enable = true;
  # ob-watcher gets buggy after running for a while, so periodically restart
  systemd.services.joinmarket-ob-watcher = rec {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RuntimeMaxSec = "1 week";
    };
  };

  services.electrs.enable = true;

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

  nix-bitcoin.netns-isolation.enable = true;

  programs.extra-container.enable = true;

  services.postgresql.enableJIT = true;

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  environment.variables = {
    # Use 24h time format
    LC_TIME = "C.UTF-8";
  };

  nix-bitcoin.configVersion = "0.0.85";
}
