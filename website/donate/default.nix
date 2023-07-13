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
      btcpayserverPayButtonId = mkOption {
        type = types.str;
      };
    };
  };

  cfg = config.nixbitcoin-org.website.donate;

  mkPage = import ./make-donation-page.nix { inherit pkgs; };

  webpageFile = "/var/cache/nginx/donate.htm";

  lnurlPath = "/btcpayserver/BTC/UILNURL/${cfg.btcpayserverPayButtonId}/pay";

  btcpayserverAddress = with config.services.btcpayserver; "${address}:${toString port}";
in {
  inherit options;

  config = {
    systemd.services = mkIf config.nixbitcoin-org.website.enable {
      # Fetches the invoice-based btcpayserver donation page and amends it
      # with LNURL payment info.
      make-donation-page = let
        args = mkPage.mkServiceArgs {
          output_file = webpageFile;
          title = "Donate - nix-bitcoin";
          invoice_donation_page_url = "http://${config.nixbitcoin-org.website.nginxAddress}/donate/multi";
          lnurl_plaintext = "https://nixbitcoin.org/donate/lightning";
          lightning_address = "donate@nixbitcoin.org";
        };
      in rec {
        requires = [ "btcpayserver.service" "nginx.service" ];
        wantedBy = requires ++ [ "multi-user.target" ];
        bindsTo = requires;
        after = requires;
        inherit (args) environment;
        serviceConfig = {
          User = config.services.nginx.user;
          inherit (args) ExecStart;
          Restart = "on-failure";
          RestartSec = "30s";
        };
      };
    };

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
        alias ${webpageFile};
      }

      location = /donate/multi {
        rewrite ^ /btcpayserver/apps/${cfg.btcpayserverAppId}/pos;
      }

      # Forward the LUD-06 lnurl location to btcpayserver
      location = /donate/lightning {
        rewrite ^ ${lnurlPath};
      }

      # Forward all LUD-16 lightning addresses (*@nixbitcoin.org) to btcpayserver
      location /.well-known/lnurlp/ {
        rewrite ^ ${lnurlPath};
      }

      location /btcpayserver/ {
        proxy_pass http://${btcpayserverAddress};

        expires off;

        # Disallow access to the btcpayserver admin interface and the API
        location ~* ^/btcpayserver/(login|register|account|api|)(?:$|/) {
          return 404;
        }

        ## Add extra rate limits for invoice generation

        # 1. Rate-limit the paybutton app used for lnurl
        location /btcpayserver/BTC/UILNURL/${cfg.btcpayserverPayButtonId} {
          return 590;
        }
        # An alias
        location /btcpayserver/BTC/LNURL/${cfg.btcpayserverPayButtonId} {
          return 590;
        }
        location /btcpayserver/api/v1/invoices {
          return 590;
        }

        # 2. Rate-limit the regular app (/donate/multi)
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

    nix-bitcoin.pkgOverlays = super: self: {
      # btcpayserver 1.10.4 pre-release, required for LNURL
      # TODO-EXTERNAL: Remove this when included in nixpkgs
      btcpayserver = self.pinned.pkgs.callPackage ./../../pkgs/btcpayserver {};
    };
  };
}
