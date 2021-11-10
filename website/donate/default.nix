{ config, lib, pkgs, ... }:

with lib;
let
  options = {
    nix-bitcoin-org.website.donate = {
      btcpayserverAppId = mkOption {
        type = types.str;
      };
      btcpayserverAppIdLnurl = mkOption {
        type = types.str;
      };
    };
  };

  cfg = config.nix-bitcoin-org.website.donate;

  donate = import ./make-donation-page.nix { pkgs = config.nix-bitcoin.pkgs.pinned.pkgsUnstable; };

  webpage = donate.mkPage {
    title = "Donate - nix-bitcoin";
    lnurl_plaintext = "https://nixbitcoin.org/donate/lightning";
    donate_other_methods_url = "/donate/other";
    lightning_address = "donate@nixbitcoin.org";
  };

  btcpayserverPayRequest = "/btcpayserver/BTC/LNURL/pay/app/${cfg.btcpayserverAppIdLnurl}/donate";

  btcpayserverAddress = with config.services.btcpayserver; "${address}:${toString port}";
in {
  inherit options;

  config = {
    # Allow 2 invoices per minute and IP, with a burst limit of 10.
    # See the `rate limiting` comment in ../default.nix for details.
    services.nginx.commonHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=btcp_invoice:10m rate=2r/m;
    '';

    nix-bitcoin-org.website.nginxHostConfig =''
      location /btcpayserver/ {
        proxy_pass http://${btcpayserverAddress};

        # Disallow access to the btcpayserver admin interface and the API
        location ~* ^/btcpayserver/(login|register|account|api|)(?:$|/) {
          return 404;
        }

        ## Add extra rate limits for invoice generation

        # 1. Rate-limit the lnurl app
        location /btcpayserver/BTC/LNURL/pay/app/${cfg.btcpayserverAppIdLnurl} {
          proxy_pass http://${btcpayserverAddress};
          limit_req zone=btcp_invoice burst=10 nodelay;
        }

        # 2. Rate-limit the regular app (/donate/other)
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
        limit_req zone=btcp_invoice burst=10 nodelay;
        proxy_pass http://${btcpayserverAddress};
      }

      location = /donate {
        default_type "text/html";
        alias ${webpage};
      }

      location = /donate/other {
        rewrite ^ /btcpayserver/apps/${cfg.btcpayserverAppId}/pos;
      }

      # Forward the fixed location lnurl to btcpayserver (lnurl LUD-06)
      location = /donate/lightning {
        rewrite ^ ${btcpayserverPayRequest};
      }

      # Forward all lightning addresses (*@nixbitcoin.org) to btcpayserver (lnurl LUD-16)
      location /.well-known/lnurlp/ {
        rewrite ^ ${btcpayserverPayRequest};
      }
    '';
  };
}
