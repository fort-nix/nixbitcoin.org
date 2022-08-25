{ config, lib, pkgs, ... }:

with lib;
let
  nbLib = config.nix-bitcoin.lib;

  mempoolConfig = mkIf config.nixbitcoin-org.website.enable {
    systemd.tmpfiles.rules = [
      "L+ /var/www/mempool - - - - ${config.services.mempool.frontend.staticContentRoot}"
    ];

    services.nginx = {
      # `frontend.nginxConfig.httpConfig` is already set by `mempool.frontend`
      # Setup backend API caches
      commonHttpConfig = ''
        proxy_cache_path
          /var/cache/nginx/mempool-api
          keys_zone=mempool_api:20m
          max_size=200m
          inactive=5d
          levels=1:2
          use_temp_path=off;
      '';

      virtualHosts."mempool" = {
        extraConfig = mkForce mempoolServerConfig;
      };

      virtualHosts."mempool.nixbitcoin.org" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/mempool";
        extraConfig = mempoolServerConfig + ''
          add_header Onion-Location http://4fyxfiqjn2sqe3smk7s6lgbhakwj4un3p7rj6j5oozfl6slnxphzslid.onion$request_uri;
        '';
      };

      upstreams = {
        "mempool-backend" = let
          backend = config.services.mempool;
        in {
          servers = { ${nbLib.addressWithPort backend.address backend.port} = {}; };
          extraConfig = ''
            keepalive 16;
          '';
        };
      };
    };
  };

  mempoolServerConfig = let
    conf = pkgs.writeText "mempool-server-conf" (
      config.services.mempool.frontend.nginxConfig.staticContent +
      builtins.readFile ./mempool-api.conf
    );
  in ''
    include ${conf};
  '';

in
mempoolConfig
