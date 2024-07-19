{ config, lib, pkgs, ... }:

# See ../../test/btcpayserver-config/create-btcpayserver-config.md
# on how to configure a btcpayserver instance that backs this donations page

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

  inherit (import ./make-donation-page.nix { inherit pkgs; }) mkDonationPage;

  btcpayserverAddress = with config.services.btcpayserver; "${address}:${toString port}";

  donationPage = mkDonationPage {
    lnurl_plaintext = "https://nixbitcoin.org/donate/lightning";
    lightning_address = "donate@nixbitcoin.org";
    btcpayserver_app_id = cfg.btcpayserverAppId;
  };

  nbLib = config.nix-bitcoin.lib;
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
        default_type "text/html";
        alias ${donationPage}/index.html;
      }

      location = /site.css {
        alias ${donationPage}/site.css;
      }

      # Forward the LUD-06 LNURL location to btcpayserver
      location = /donate/lightning {
        rewrite ^ /btcpayserver/.well-known/lnurlp/donate;
      }

      # Forward all LUD-16 lightning addresses (*@nixbitcoin.org) to btcpayserver
      location /.well-known/lnurlp/ {
        rewrite ^ /btcpayserver/.well-known/lnurlp/donate;
      }

      location /btcpayserver/ {
        proxy_pass http://${btcpayserverAddress};

        expires off;

        # Disallow access to the btcpayserver admin interface and the API
        location ~* ^/btcpayserver/(login|register|account|api|)(?:$|/) {
          return 404;
        }

        ## Add extra rate limits for invoice generation

        # 1. Rate-limit LNURL invoice creation
        location /btcpayserver/BTC/UILNURL/pay/lnaddress/donate {
          return 590;
        }
        # An alias
        location /btcpayserver/BTC/LNURL/pay/lnaddress/donate {
          return 590;
        }

        # 2. Rate-limit the regular app
        # GET requests to this location only return the donation interface.
        # Add extra rate limiting only for POST requests where invoice generation happens.
        #
        location /btcpayserver/apps/${cfg.btcpayserverAppId} {
          if ($request_method = POST) {
            # Return to a named location (@btcp_limit_post) because `if` statements
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

    # After a while of inactivity btcpayserver responds very slowly to new invoice
    # requests.
    # Fix this by periodically requesting an invoice.
    systemd = {
      services.btcpayserver-warmup-invoice = rec {
        wantedBy = [ "multi-user.target" ];
        requires = [ "btcpayserver.service" ];
        after = requires;
        path = with pkgs; [ curl jq ];
        script = ''
          curl -i -fsS '${btcpayserverAddress}/btcpayserver/apps/${cfg.btcpayserverAppId}/pos' \
            --data-raw  'requiresRefundEmail=InheritFromStore&amount=1.234'
        '';
        serviceConfig = nbLib.defaultHardening // nbLib.allowLocalIPAddresses // {
          user = "nobody";
        };
      };
      timers.btcpayserver-warmup-invoice = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # Run every 6h
          OnUnitActiveSec = "6h";
          AccuracySec = "10m";
        };
      };
    };
  };
}
