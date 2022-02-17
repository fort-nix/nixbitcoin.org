{ config, lib, pkgs, ... }:

with lib;
let
  options = {
    nix-bitcoin-org.website = {
      enable = mkEnableOption "nix-bitcoin.org website";
      nginxHostConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Common Nginx config included in all `server` blocks.
        '';
      };
    };
  };

  cfg = config.nix-bitcoin-org.website;

  nginxAddress = if config.nix-bitcoin.netns-isolation.enable then
    config.nix-bitcoin.netns-isolation.netns.nginx.address
  else
    "localhost";

  torConnectionSrc = config.nix-bitcoin.netns-isolation.bridgeIp;
in {
  imports = [
    ./donate
    ./orderbook.nix
  ];

  inherit options;

  config = mkIf cfg.enable (mkMerge [
  {
    systemd.tmpfiles.rules = [
      # Create symlink to static website content
      "L+ /var/www/main - - - - ${./static}"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      email = "nixbitcoin@i2pmail.org";
      acceptTerms = true;
    };

    services.btcpayserver.rootpath = "btcpayserver";

    nix-bitcoin-org.website.nginxHostConfig = mkBefore ''
      root /var/www/main;
      add_header Onion-Location http://qvzlxbjvyrhvsuyzz5t63xx7x336dowdvt7wfj53sisuun4i4rdtbzid.onion$request_uri;
    '';

    services.nginx = let
      hostConfig.extraConfig = ''
        include ${pkgs.writeText "common.conf" cfg.nginxHostConfig};
      '';
    in {
      enable = true;
      enableReload = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
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

        # Disable the access log for user privacy
        access_log off;
      '';
      virtualHosts."nixbitcoin.org" = hostConfig // {
        forceSSL = true;
        enableACME = true;
      };
      virtualHosts."_" = hostConfig;
      virtualHosts."mempool.nixbitcoin.org" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/mempool/browser";
        extraConfig = ''
          add_header Cache-Control "public, no-transform";

          add_header Vary Accept-Language;
          add_header Vary Cookie;

          location / {
                  try_files /$lang/$uri /$lang/$uri/ $uri $uri/ /en-US/$uri @index-redirect;
                  expires 10m;
          }
          location /resources {
                  try_files /$lang/$uri /$lang/$uri/ $uri $uri/ /en-US/$uri @index-redirect;
                  expires 1h;
          }
          location @index-redirect {
                  rewrite (.*) /$lang/index.html;
          }

          location ~ ^/(ar|bg|bs|ca|cs|da|de|et|el|es|eo|eu|fa|fr|gl|ko|hr|id|it|he|ka|lv|lt|hu|mk|ms|nl|ja|nb|nn|pl|pt|pt-BR|ro|ru|sk|sl|sr|sh|fi|sv|th|tr|uk|vi|zh|hi)/resources/ {
                  rewrite ^/[a-zA-Z-]*/resources/(.*) /en-US/resources/$1;
          }
          location ~ ^/(ar|bg|bs|ca|cs|da|de|et|el|es|eo|eu|fa|fr|gl|ko|hr|id|it|he|ka|lv|lt|hu|mk|ms|nl|ja|nb|nn|pl|pt|pt-BR|ro|ru|sk|sl|sr|sh|fi|sv|th|tr|uk|vi|zh|hi)/ {
                  try_files $uri $uri/ /$1/index.html =404;
          }

          location = /api {
                  try_files $uri $uri/ /en-US/index.html =404;
          }
          location = /api/ {
                  try_files $uri $uri/ /en-US/index.html =404;
          }

          location /api/v1/ws {
                  proxy_pass http://${config.services.mempool.backendAddress}:${toString config.services.mempool.backendPort}/;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "Upgrade";
          }
          location /api/v1 {
                  proxy_pass http://${config.services.mempool.backendAddress}:${toString config.services.mempool.backendPort}/api/v1;
          }
          location /api/ {
                  proxy_pass http://${config.services.mempool.backendAddress}:${toString config.services.mempool.backendPort}/api/v1/;
          }

          location /ws {
                  proxy_pass http://${config.services.mempool.backendAddress}:${toString config.services.mempool.backendPort}/;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "Upgrade";
          }
          add_header Onion-Location http://m5ylnqzeqwjifgdp6cveveiwsaqodu444uiyjjz2vrmfhsfgyo6em3yd.onion$request_uri;
        '';
      };
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
      externalInterface = "enp2s0";
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
