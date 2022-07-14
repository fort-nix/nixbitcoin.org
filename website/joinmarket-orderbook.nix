{ config, ... }:

let
  obAddress = with config.services.joinmarket-ob-watcher; "${address}:${toString port}";
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

      # - Cache responses for 10 minutes
      # - Only cache successful responses (Codes 200, 301, 302)
      proxy_cache_valid 10m;

      # Ignore URI query strings (?param=...) in cache keys.
      # This prevents attackers from filling the cache and evicting valid entries
      # by requesting the same resource multiple times with different parameters.
      # The orderbook doesn't use query strings in URIs.
      proxy_cache_key $scheme$uri;

      # If there are more than one parallel requests to the same uncached ressource,
      # wait until the first request has populated the cache and then respond to
      # the remaining requests.
      proxy_cache_lock on;
      proxy_cache_lock_age 1m;
      proxy_cache_lock_timeout 1m;
    }

    # Redirect old obwatcher path
    location /obwatcher {
      rewrite /obwatcher(.*) /orderbook$1 permanent;
    }
 '';
}
