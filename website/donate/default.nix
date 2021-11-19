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
      }
    '';
  };
}
