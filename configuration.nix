{ config, pkgs, lib, ... }:
let
cfg = {
  imports = [
    <nix-bitcoin/modules/presets/secure-node.nix>
    <nix-bitcoin/modules/presets/hardened.nix>

    ./hardware-configuration.nix
    ./website
    ./matrix.nix
    base
    services
  ];
};

base = {
  networking.hostName = "nixbitcoin-org";
  time.timeZone = "UTC";

  services.openssh.enable = true;
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAO3kpItIalS3HHzqLRnXXFVRFtckuwE1FmytQ4HTh9u" ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "20.09";

  nix-bitcoin.configVersion = "0.0.51";
};

services = {
  nix-bitcoin.onionServices.bitcoind.public = true;

  services.bitcoind.extraConfig = ''
    whitelist=169.254.1.23
  '';

  services.clightning = {
    enable = true;
    plugins.clboss.enable = true;
    extraConfig = ''
      alias=nixbitcoin.org
    '';
  };
  nix-bitcoin.onionServices.clightning.public = true;

  services.electrs.enable = true;

  services.btcpayserver = {
    enable = true;
    lightningBackend = "clightning";
    lbtc = true;
  };
  nix-bitcoin.onionServices.btcpayserver.enable = true;

  nix-bitcoin.netns-isolation.enable = true;

  services.liquidd.extraConfig = ''
    whitelist=169.254.1.23
  '';

  services.joinmarket = {
    enable = true;
    rpcWalletFile = null;
    yieldgenerator.enable = true;
  };
  services.joinmarket-ob-watcher.enable = true;

  nix-bitcoin-org.website.enable = true;
};
in
  cfg
