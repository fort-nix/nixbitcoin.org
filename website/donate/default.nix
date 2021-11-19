{ config, lib, pkgs, ... }:

with lib;
let
  options = {
    nix-bitcoin-org.website.donate = {
      btcpayserverAppId = mkOption {
        type = types.str;
      };
    };
  };

  cfg = config.nix-bitcoin-org.website.donate;

  btcpayserverAddress = with config.services.btcpayserver; "${address}:${toString port}";
in {
  inherit options;

  config = {
    # Allow 2 invoices per minute and IP, with a burst limit of 5.
    # See the `rate limiting` comment in ../default.nix for details.
    services.nginx.commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=btcp_invoice:10m rate=2r/m;
    '';

    nix-bitcoin-org.website.nginxHostConfig = ''
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
        proxy_pass http://${btcpayserverAddress};
      }
    '';
  };
}
