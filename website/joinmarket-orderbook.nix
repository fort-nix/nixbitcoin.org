{ config, pkgs, lib, ... }:

with lib;
let
  nbLib = config.nix-bitcoin.lib;

  cfg = config.nixbitcoin-org.website;
  obAddress = with config.services.joinmarket-ob-watcher; "${address}:${toString port}";

  # Query the nginx orderbook in a regular interval to keep the cache up to date
  autoUpdateIntervalSec = 10 * 60;
  # By making the nginx cache valid duration slightly smaller than the query
  # interval, the query triggers a cache update.
  cacheValidDurationSec = autoUpdateIntervalSec - 5;
in {
  services.nginx = {
    commonHttpConfig = ''
      proxy_cache_path
        /var/cache/nginx/orderbook
        keys_zone=orderbook:1m
        max_size=100m
        # Delete cache entries that were not accessed for one month
        inactive=1M
        use_temp_path=off;
    '';
  };

  nixbitcoin-org.website.homepageHostConfig = ''
    location /orderbook/ {
      proxy_pass http://${obAddress};
      rewrite /orderbook/(.*) /$1 break;

      proxy_cache orderbook;

      # - Cache responses for `cacheValidDurationSec`
      # - Only cache successful responses (Codes 200, 301, 302)
      proxy_cache_valid ${toString cacheValidDurationSec}s;
      expires ${toString cacheValidDurationSec}s;

      # Ignore URI query strings (?param=...) in cache keys.
      # This prevents attackers from filling the cache and evicting valid entries
      # by requesting the same resource multiple times with different parameters.
      # The orderbook doesn't use query strings in URIs.
      proxy_cache_key $uri;

      # When processing a request for which the cache item is expired, return the expired item and
      # start a request to update the cache.
      # The max age of a cached response is therefore:
      # autoUpdateIntervalSec + request_processing_time
      proxy_cache_background_update on;
      proxy_cache_use_stale updating;

      # If there are more than one parallel requests to the same uncached ressource,
      # wait until the first request has populated the cache and then respond to
      # the remaining requests.
      proxy_cache_lock on;
      # Some requests can take a long time
      proxy_cache_lock_age 3m;
      proxy_cache_lock_timeout 3m;
    }

    # Redirect old obwatcher path
    location /obwatcher {
      rewrite /obwatcher(.*) /orderbook$1 permanent;
    }
  '';

  systemd = mkIf cfg.enable {
    # Keep the orderbook cache up to date
    services.orderbook-update-cache = {
      wantedBy = [ "multi-user.target" ];
      requires = [ "nginx.service" ];
      after = [ "nginx.service" ];
      script = ''
        paths=(
          ""
          fidelitybonds
          ordersize
          depth
          sybilresistance
          orderbook.json
        )
        for path in "''${paths[@]}"; do
          ${pkgs.curl}/bin/curl -sSL ${cfg.nginxAddress}/orderbook/$path >/dev/null
        done
      '';
      serviceConfig = nbLib.defaultHardening // nbLib.allowLocalIPAddresses;
    };

    timers.orderbook-update-cache = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # Run every x sec
        OnUnitActiveSec = "${toString autoUpdateIntervalSec}s";
        AccuracySec = "1s";
      };
    };
  };
}
