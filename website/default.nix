{ config, lib, pkgs, ... }:

with lib;
let
  options = {
    nixbitcoin-org.website = {
      enable = mkEnableOption "nix-bitcoin.org website";
      homepageHostConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Common Nginx config included in all `server` blocks for the homepage.
        '';
      };
      nginxAddress = mkOption {
        readOnly = true;
        default = if config.nix-bitcoin.netns-isolation.enable then
          config.nix-bitcoin.netns-isolation.netns.nginx.address
        else
          "localhost";
      };
    };
  };

  cfg = config.nixbitcoin-org.website;

  inherit (cfg) nginxAddress;

  torConnectionSrc = config.nix-bitcoin.netns-isolation.bridgeIp;
in {
  imports = [
    ./donate
    ./joinmarket-orderbook.nix
    ./mempool.nix
    ./mempool-debug.nix
    ./mempool-debug-tor.nix
  ];

  inherit options;

  config = mkIf cfg.enable (mkMerge [
  {
    systemd.tmpfiles.rules = [
      # Create symlink to static homepage content
      "L+ /var/www/main - - - - ${./static}"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      defaults.email = "nixbitcoin@i2pmail.org";
      acceptTerms = true;
    };

    services.btcpayserver.rootpath = "btcpayserver";

    nixbitcoin-org.website.homepageHostConfig = mkBefore ''
      root /var/www/main;
      add_header Onion-Location http://qvzlxbjvyrhvsuyzz5t63xx7x336dowdvt7wfj53sisuun4i4rdtbzid.onion$request_uri;
      expires 10m;
    '';

    services.nginx = let
      homepageHostCfg.extraConfig = ''
        include ${pkgs.writeText "common.conf" cfg.homepageHostConfig};
      '';
    in {
      enable = true;
      enableReload = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      appendConfig = ''
        worker_processes ${
          toString (max 1 (builtins.floor (config.nixbitcoinorg.hardware.numCPUs * 0.6)))
        };
        worker_rlimit_nofile 8192;
        pcre_jit on;
      '';
      eventsConfig = ''
        worker_connections 4096;
      '';
      commonHttpConfig = ''
        # Disable the access log for user privacy
        access_log off;
      ''
        # Rate limiting
      + ''
        # Add rate limiting:
        # At any given time, the number of total requests per IP is limited to
        # 1 + rate * time_elapsed + burst
        #
        # Additional requests are rejected with error 429.

        # Activate rate limit zones `global` or `global_tor`,
        # depending on the source address of the request
        geo $limit {
          default 0;
          ${torConnectionSrc} 1;
        }
        map $limit $limit_key_clearnet {
          0 $binary_remote_addr;
          1 "";
        }
        map $limit $limit_key_tor {
          0 "";
          1 $binary_remote_addr;
        }

        # Zone `global`, only active for clearnet connections
        limit_req_zone $limit_key_clearnet zone=global:10m rate=30r/s;

        # Zone `global_tor`, only active for tor connections.
        # This zone only tracks one source address (torConnectionSrc), so
        # set the smallest zone size allowed by nginx (32k).
        limit_req_zone $limit_key_tor zone=global_tor:32k rate=300r/s;

        # Use zones by default in all locations
        limit_req zone=global burst=20 nodelay;
        limit_req zone=global_tor burst=20 nodelay;

        # 429: "Too Many Requests"
        limit_conn_status 429;
        limit_req_status 429;
      '';

      virtualHosts."nixbitcoin.org" = homepageHostCfg // {
        forceSSL = true;
        enableACME = true;
      };
      # Used by Tor
      virtualHosts."_" = homepageHostCfg;
    };

    services.tor.relay.onionServices.nginx = {
      map = [
        rec { port = 80;  target = { addr = nginxAddress; inherit port; }; }
        rec { port = 443; target = { addr = nginxAddress; inherit port; }; }
      ];
      version = 3;
    };
  }

  (mkIf config.nix-bitcoin.netns-isolation.enable {
    nix-bitcoin.netns-isolation.services.nginx.connections = [ "btcpayserver" "joinmarket-ob-watcher" ];

    # Forward HTTP(S) connections to the namespaced nginx address
    networking.nat = {
      enable = true;
      externalInterface = "eth0";
      forwardPorts = [
        {
          proto = "tcp";
          destination = "${nginxAddress}:80";
          sourcePort = 80;
        }
        {
          proto = "tcp";
          destination = "${nginxAddress}:443";
          sourcePort = 443;
        }
      ];
    };

    # Allow HTTP(S) connections to nginx from outside netns
    systemd.services.netns-nginx.postStart = ''
      ${pkgs.iproute}/bin/ip netns exec nb-nginx ${config.networking.firewall.package}/bin/iptables \
        -w -A INPUT -p TCP -m multiport --dports 80,443 -j ACCEPT
    '';

    systemd.services."acme-nixbitcoin.org".serviceConfig.NetworkNamespacePath = "/var/run/netns/nb-nginx";
  })
  ]);
}
