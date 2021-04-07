{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-bitcoin-org.website;

  nginxAddress = if config.nix-bitcoin.netns-isolation.enable then
    config.nix-bitcoin.netns-isolation.netns.nginx.address
  else
    "localhost";

  serviceAddress = service:
    with config.services.${service};
    "${address}:${toString port}";

in {
  options.nix-bitcoin-org.website = {
    enable = mkEnableOption "nix-bitcoin.org website";
  };

  config = mkIf cfg.enable (mkMerge [
  {
    systemd.tmpfiles.rules = [
      # Create symlink to static website content
      "L+ /var/www - - - - ${./static}"
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      email = "nixbitcoin@i2pmail.org";
      acceptTerms = true;
    };

    services.nginx = let
      hostConfig = {
        root = "/var/www";
        locations."/btcpayserver/" = {
          proxyPass = "http://${serviceAddress "btcpayserver"}";
        };
        extraConfig = ''
          # Disallow access to the admin interface
          location ~* ^/btcpayserver/(login|register|account)(?:$|/) {
            return 404;
          }

          location /obwatcher/ {
            proxy_pass http://${serviceAddress "joinmarket-ob-watcher"};
            rewrite /obwatcher/(.*) /$1 break;
          }

          add_header Onion-Location http://qvzlxbjvyrhvsuyzz5t63xx7x336dowdvt7wfj53sisuun4i4rdtbzid.onion$request_uri;
        '';
      };
    in {
      enable = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      commonHttpConfig = ''
        # Disable the access log for user privacy
        access_log off;
      '';
      virtualHosts."nixbitcoin.org" = hostConfig // {
        forceSSL = true;
        enableACME = true;
      };
      virtualHosts."_" = hostConfig;
    };

    services.btcpayserver.rootpath = "btcpayserver";

    services.tor.hiddenServices.nginx = {
      map = [{
        port = 80; toHost = nginxAddress;
      } {
        port = 443; toHost = nginxAddress;
      }];
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
