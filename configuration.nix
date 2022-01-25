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
  networking.hostName = "nixbitcoin";
  time.timeZone = "UTC";

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjOWkBbvyTd5VhlWHecyAbsTFbQyxnXOJw+or9uQG5fbq7DlQFhFbDpD62jUzoNlsmfeLOgudyrD5A++Mk8NQLzGauBvmjql5RmfL1ZScqHPQi01sXQcEqbCRRR7O4tBynpJYktXGs7QJOIPikPBDBP2hBIxKkuHfv2nryiDcOT3DxgWbzEqvCRfHlH/D5NimPFP142gyGALbItCEBjoNKOPEOj/9t4FGEwXlX7bmggVLfIi6GakgxF78V2X1+5RIlQWbvfMrfQWSjKzqdS/vIqp7jZJziK66lqrJo+BQGNorh81Bsgy/p0SMdv8KoN3Xvrdxf/4pyADxmkyr1y5ryGabMHy2xqB3gna6XrrJThhMEbOD1xfwOZ7vKDu8YIfK1wzXnt3cwl+fHMlPicmi/Vh2qkYuBPbVxo1g5+XyCq9roatdvzsVdSX3+a1U1CeGee1q1p8Hf8oY5PrQBhv80RqI3HAbr3tdZD7HlPL9XY9arbm4XP67qrxM+P1L4eBx5N9vCkOjKs0Pp1XHwyfGGiTYFYsZCR6MG8SKZ6Q+zWR4UKTEgY0rNT2//wlnDlkaUl6OYAKJUYtxffZo5WjIpqAzq7qSi+Me0AD/M6QPRZpXjKOrlisagO9uV9/WycV/pVjryJcmlhyDlAwaTQeypyleeryxHNEwBYoVdyMz52Q==" # nixbitcoindev
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVyeXpwHsOV8RMtQwzPGhOlJ8n5/+4hGa2jc7T47CJC" # nickler
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW0rZHTE+/gRpbPVw0Q6Wr3csEgU7P+Q8Kw6V2xxDsG" # Erik Arvstedt
    ];
  };

  # Refused connections are happening constantly on a public server and can be ignored
  networking.firewall.logRefusedConnections = false;

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "20.09";

  nix-bitcoin.configVersion = "0.0.57";
};

services = {
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
  services.rtl.nodes.clightning = true;

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
    rpcWalletFile = null;
    yieldgenerator.enable = true;
  };
  services.joinmarket-ob-watcher.enable = true;

  nix-bitcoin-org.website = {
    enable = true;
    donate.btcpayserverAppId = "4D1Dxb5cGnXHRgNRBpoaraZKTX3i";
  };

  services.backups = {
    enable = true;
    destination = "sftp://nixbitcoin@freak.seedhost.eu";
  };
  programs.ssh.knownHosts."freak.seedhost.eu".publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD2TmdE89ZD4XshcIcXZPLFC/nDxZdAr9yrH2/2OCNKEo/Ex60y8TQjp93isjdDj7Grf/GpW60OONfXTFe0r5iM=";

  # TODO-EXTERNAL
  # Remove this when https://github.com/NixOS/nixpkgs/issues/148009 is resolved
  systemd.services.nginx.serviceConfig.SystemCallFilter =
    lib.mkForce "~@cpu-emulation @debug @keyring @ipc @mount @obsolete @privileged @setuid";
};
in
  cfg
