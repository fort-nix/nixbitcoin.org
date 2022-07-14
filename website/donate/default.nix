{ config, lib, pkgs, ... }:

with lib;
let
  options = {
    nixbitcoin-org.website.donate = {
      btcpayserverAppId = mkOption {
        type = types.str;
      };
    };
  };

  cfg = config.nixbitcoin-org.website.donate;

  btcpayserverAddress = with config.services.btcpayserver; "${address}:${toString port}";
in {
  inherit options;

  config = {
    # Clearnet: Allow 2 invoices per minute and IP, with a burst limit of 5.
    # Tor: Allow 30 invoices per minute, with a burst limit of 5.
    #
    # See the `rate limiting` comment in ../default.nix for details.
    services.nginx.commonHttpConfig = mkAfter ''
      limit_req_zone $limit_key_clearnet zone=btcp_invoice:10m rate=2r/m;
      limit_req_zone $limit_key_tor zone=btcp_invoice_tor:32k rate=30r/m;
    '';

    nixbitcoin-org.website.homepageHostConfig = ''
      location = /donate {
        rewrite /donate /btcpayserver/apps/${cfg.btcpayserverAppId}/pos;
      }

      location /btcpayserver/ {
        proxy_pass http://${btcpayserverAddress};

        # Disallow access to the btcpayserver admin interface and the API
        location ~* ^/btcpayserver/(login|register|account|api|)(?:$|/) {
          return 404;
        }

        ## Add extra rate limits for invoice generation

        # GET requests to this location only return the donation interface.
        # Add extra rate limiting only for POST requests where invoice generation happens.
        #
        location /btcpayserver/apps/${cfg.btcpayserverAppId} {
          if ($request_method = POST) {
            # Return to a named location (@btcp) because `if` statements
            # inside location blocks may only return or rewrite.
            return 590;
          }
          proxy_pass http://${btcpayserverAddress};
        }
      }

      # Required for jumping to named location @btcp_limit_post
      error_page 590 = @btcp_limit_post;

      location @btcp_limit_post {
        limit_req zone=btcp_invoice burst=5 nodelay;
        limit_req zone=btcp_invoice_tor burst=5 nodelay;
        proxy_pass http://${btcpayserverAddress};
      }
    '';
  };
}
