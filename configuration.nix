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

  services.joinmarket = {
    enable = true;
    yieldgenerator.enable = true;
    settings."MESSAGING:onion".directory_nodes = lib.mkForce "3kxw6lf5vf6y26emzwgibzhrzhmhqiw6ekrek3nqfjjmhwznb2moonad.onion:5222,bqlpq6ak24mwvuixixitift4yu42nxchlilrcqwk2ugn45tdclg42qid.onion:5222,odpwaf67rs5226uabcamvypg3y4bngzmfk7255flcdodesqhsvkptaid.onion:5222,ylegp63psfqh3zk2huckf2xth6dxvh2z364ykjfmvsoze6tkfjceq7qd.onion:5222,coinjointovy3eq5fjygdwpkbcdx63d7vd4g32mw7y553uj3kjjzkiqd.onion:5222,satoshi2vcg5e2ept7tjkzlkpomkobqmgtsjzegg6wipnoajadissead.onion:5222,shssats5ucnwdpbticbb4dymjzf2o27tdecpes35ededagjpdmpxm6yd.onion:5222,jmarketxf5wc4aldf3slm5u6726zsky52bqnfv6qyxe5hnafgly6yuyd.onion:5222";
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
