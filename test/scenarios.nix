{ pkgs, lib, scenarios }:
with lib;
rec {
  # Included in all scenarios
  base = {
    imports = [ <nix-bitcoin/test/lib/test-lib.nix> ];
  };

  nixbitcoinorg = { config, ... }: {
    imports = [
      ../configuration.nix
      scenarios.regtestBase
      disableFeatures
      ./btcpayserver-config
    ];
    # Ignore hardware config that is specific to the production server
    disabledModules = [ ../hardware.nix ];

    # Improve eval performance by reusing pkgs
    nixpkgs.pkgs = pkgs;

    nix-bitcoin.generateSecrets = true;

    networking.nat.externalInterface = mkForce "eth0";

    nixbitcoinorg.hardware = {
      numCPUs = 2;
      memorySizeGiB = 4;
    };

    # Make the btcpayserver admin interface accessible at $nodeIP:23000/btcpayserver
    networking.nat.extraCommands = let
      btcp = config.services.btcpayserver;
      address = btcp.address;
      port = toString btcp.port;
      interface = config.networking.nat.externalInterface;
      netnsBridgeIp = config.nix-bitcoin.netns-isolation.bridgeIp;
    in ''
      iptables -w -t nat -A nixos-nat-pre -i ${interface} -p tcp --dport ${port} -j DNAT --to-destination ${address}
      # Add source NAT to the bridge address because the btcpayserver netns doesn't allow connections to external addresses.
      iptables -w -t nat -A nixos-nat-post -p tcp -d ${address} -j SNAT --to-source ${netnsBridgeIp}
    '';
  };

  # Disable features that should only run in production or that
  # slow down testing
  disableFeatures = {
    ## Disable ACME for local testing
    security.acme = mkForce {};
    services.nginx.virtualHosts =
      let
        disableACME = {
          enableACME = mkForce false;
          forceSSL = mkForce false;
        };
      in {
        "nixbitcoin.org" = disableACME;
        "element.nixbitcoin.org" = disableACME;
        "mempool.nixbitcoin.org" = disableACME;
        "synapse.nixbitcoin.org" = disableACME;
      };
    # Disable mailserver by default because it has no option for fast offline cert generation.
    mailserver.enable = mkForce false;
    # To test the mailserver, enable the mailserver and uncomment the line below:
    # mailserver.certificateScheme = mkForce 2;

    # joinmarket-ob-watcher doesn't work in regtest mode or requires a synced
    # bitcoind node on mainnet
    systemd.services.joinmarket-ob-watcher.wantedBy = mkForce [];

    ## The following features delay system startup when WAN in unavailable.
    # This is always the case in containers because network is only available
    # after container startup completed.

    # When WAN is not available, DNS bootstrapping slows down service startup by ~15 s.
    services.clightning.extraConfig = "disable-dns";

    # Disable clboss when WAN is disabled until the delayed startup issue is fixed:
    # https://github.com/ZmnSCPxj/clboss/issues/49
    services.clightning.plugins.clboss.enable = mkForce false;
  };

  # Include this to deactivate all features.
  # You can then re-activate specific features for quick testing.
  noFeatures = let
    testDefault = mkOverride 60;
  in {
    services.bitcoind.i2p = testDefault false;
    services.electrs.enable = testDefault false;
    services.clightning.enable = testDefault false;
    services.btcpayserver.enable = testDefault false;
    services.joinmarket.enable = testDefault false;
    systemd.services.matrix-synapse.wantedBy = testDefault [];
    nixbitcoin-org.website.enable = testDefault false;
  };

  website = { config, ... }: {
    imports = [
      nixbitcoinorg
      noFeatures
    ];
    nixbitcoin-org.website.enable = mkForce true;
    services.clightning.enable = mkForce true;
    services.btcpayserver.enable = mkForce true;
    # Required for btcpayserver currency rate fetching
    test.container.enableWAN = true;
    environment.variables.WANEnabled = "1";
  };

  # To demonstrate failures in the test runner
  fail = { config, ... }: {
    systemd.services.long = {
      wantedBy = [ "multi-user.target" ];
      preStart = "sleep 3";
      script = "echo hi";
    };
    systemd.services.fail1 = {
      wantedBy = [ "multi-user.target" ];
      script = "false";
    };
    systemd.services.fail2 = {
      wantedBy = [ "multi-user.target" ];
      script = "false";
    };
    systemd.services.invalidUnit = {
      wantedBy = [ "multi-user.target" ];
      script = "";
    };
  };
}
