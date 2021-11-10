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
    nix-bitcoin-org.website.nginxHostConfig =''
      location /btcpayserver/ {
        proxy_pass http://${btcpayserverAddress};

        # Disallow access to the btcpayserver admin interface and the API
        location ~* ^/btcpayserver/(login|register|account|api|)(?:$|/) {
          return 404;
        }
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
