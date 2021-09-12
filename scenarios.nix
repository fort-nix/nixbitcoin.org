{ pkgs, lib, scenarios }:
with lib;
rec {
  # Don't use the default test base scenario
  base = {};

  nixbitcoinorg = { config, ... }: {
    imports = [
      ./configuration.nix
      scenarios.regtestBase
      # Needed by regtestBase
      <nix-bitcoin/test/lib/test-lib.nix>
    ];

    # Improve eval performance by reusing pkgs
    nixpkgs.pkgs = pkgs;

    nix-bitcoin.generateSecrets = true;

    networking.nat.externalInterface = mkForce "eth0";

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
        "synapse.nixbitcoin.org" = disableACME;
        "element.nixbitcoin.org" = disableACME;
      };
    # Disable mailserver because it has no option for fast offline cert generation.
    # `mailserver.certificateScheme = 2` works offline but is too slow.
    mailserver.enable = mkForce false;

    # When WAN is disabled, DNS bootstrapping slows down service startup by ~15 s.
    services.clightning.extraConfig = "disable-dns";

    # Disable clboss in offline mode until the delayed startup issue is fixed:
    # https://github.com/ZmnSCPxj/clboss/issues/49
    services.clightning.plugins.clboss.enable = mkIf config.test.noConnections (mkForce false);

    # Make the btcpayserver admin interface accessible at $nodeIP:23000/btcpayserver
    networking.nat.extraCommands = let
      btcp = config.services.btcpayserver;
      address = btcp.address;
      port = toString btcp.port;
      interface = config.networking.nat.externalInterface;
    in ''
      iptables -w -t nat -A nixos-nat-pre -i ${interface} -p tcp --dport ${port} -j DNAT --to-destination ${address}
      # Add source NAT to the bridge address because the btcpayserver netns doesn't allow connections to external addresses.
      iptables -w -t nat -A nixos-nat-post -p tcp -d ${address} -j SNAT --to-source 169.254.1.10
    '';
  };

  nixbitcoinorg-container = {
    imports = [ nixbitcoinorg ];
    # This service fails if apparmor is not enabled in the host kernel
    security.apparmor.enable = mkForce false;
  };

  # Disable the hardened preset to improve VM performance
  nixbitcoinorg-non-hardened = {
    imports = [ nixbitcoinorg ];
    disabledModules = [ <nix-bitcoin/modules/presets/hardened.nix> ];
  };
}
