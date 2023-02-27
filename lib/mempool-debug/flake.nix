{
  inputs.nix-bitcoin.url = "github:erikarvstedt/nix-bitcoin/misc-12";
  inputs.nix-bitcoin-mempool = {
    url = "github:erikarvstedt/nix-bitcoin-mempool";
    inputs.nix-bitcoin.follows = "nix-bitcoin";
  };

  outputs = { nix-bitcoin, nix-bitcoin-mempool, ... }: let
    system = "x86_64-linux";
    nixpkgs = nix-bitcoin.inputs.nixpkgs;
    pkgs = nixpkgs.legacyPackages.${system};

    containerMempool = let
      addressPrefix = "10.10.0";
    in { pkgs, ... }: {
      containers.mempool = {
        extra.addressPrefix = addressPrefix;
        extra.enableWAN = true;
        bindMounts."/host-secrets" = { hostPath = "/var/src/secrets"; };
        config = {
          imports = [ baseConfig ];

          nixpkgs.pkgs = pkgs;
        };
      };
      systemd.services."container@mempool" = addNetnsAccess "${addressPrefix}.2";
    };

    containerMempoolTor = let
      addressPrefix = "10.10.1";
    in { pkgs, ... }: {
      containers.mempool-tor = {
        extra.addressPrefix = addressPrefix;
        extra.enableWAN = true;
        bindMounts."/host-secrets" = { hostPath = "/var/src/secrets"; };
        config = {
          imports = [ baseConfig ];

          services.tor = {
            enable = true;
            client.enable = true;
          };

          services.mempool.tor = {
            proxy = true;
            enforce = true;
          };

          nixpkgs.pkgs = pkgs;
        };
      };
      systemd.services."container@mempool-tor" = addNetnsAccess "${addressPrefix}.2";
    };

    baseConfig = { config, pkgs, lib, ... }: {
      imports = [
        nix-bitcoin.nixosModules.default
        (nix-bitcoin + "/modules/presets/bitcoind-remote.nix")
        nix-bitcoin-mempool.nixosModules.default
      ];

      # Copy required secrets at system start, then unmount the host secrets dir
      # With systemd 252 (NixOS 22.11 only has version 251) we could just
      # mount the host secrets dir with option `rootidmap`, and keep it mounted.
      # With this option, secrets with non-root uids/guids are mapped to nobody/nogroup.
      # extraFlags = [ "--bind-ro=/var/src/secrets:/host-secrets:rootidmap" ];
      system.activationScripts.copySecrets = ''
         if mountpoint -q /host-secrets; then
           dir=${config.nix-bitcoin.secretsDir}
           mkdir -p -m 700 $dir
           cp /host-secrets/bitcoin-rpcpassword-{privileged,public} $dir
           umount /host-secrets
         fi
      '';

      nix-bitcoin.generateSecrets = true;

      services.mempool = {
        enable = true;
        frontend.enable = false;
        electrumServer = "fulcrum";
        autoRestartInterval = null;
      };

      networking.firewall.allowedTCPPorts = [ config.services.mempool.port ];

      services.bitcoind = rec {
        address = "169.254.1.12";
        rpc.address = address;
      };

      services.fulcrum = {
        address = "169.254.1.31";
        port = 50011;
      };

      # Add dummy fulcrum service
      systemd.services.fulcrum = {
        preStart = lib.mkForce "";
        serviceConfig = {
          Type = lib.mkForce "oneshot";
          ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";
          RemainAfterExit = true;
        };
      };

      services.openssh = {
        enable = true;
        # https://askubuntu.com/questions/48129/how-to-create-a-restricted-ssh-user-for-port-forwarding
        extraConfig = ''
          Match user guest
            ForceCommand echo 'This account can only be used to forward 127.0.0.1:9229'
            PermitOpen 127.0.0.1:9229
            AllowAgentForwarding no
            PasswordAuthentication no
        '';
        hostKeys = lib.mkForce [
          {
            path = "/etc/ssh-host-key";
            type = "ed25519";
          }
        ];
      };

      users.users.guest = {
        isSystemUser = true;
        group = "guest";
        shell = "${pkgs.coreutils}/bin/false";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW0rZHTE+/gRpbPVw0Q6Wr3csEgU7P+Q8Kw6V2xxDsG" # Erik Arvstedt
        ];
      };
      users.groups.guest = {};
    };

    ip = "${pkgs.iproute}/bin/ip";
    iptables = "${pkgs.iptables}/bin/iptables";
    addNetnsAccess = containerSrcAddress: {
      preStart = ''
        ${ip} netns exec nb-bitcoind ${iptables} -w -A INPUT -s ${containerSrcAddress} -j ACCEPT
        ${ip} netns exec nb-fulcrum  ${iptables} -w -A INPUT -s ${containerSrcAddress} -j ACCEPT
        ${ip} netns exec nb-fulcrum  ${iptables} -w -A OUTPUT -d ${containerSrcAddress} -j ACCEPT
      '';
      postStop = ''
        ${ip} netns exec nb-fulcrum  ${iptables} -w -D OUTPUT -d ${containerSrcAddress} -j ACCEPT || true
        ${ip} netns exec nb-fulcrum  ${iptables} -w -D INPUT -s ${containerSrcAddress} -j ACCEPT || true
        ${ip} netns exec nb-bitcoind ${iptables} -w -D INPUT -s ${containerSrcAddress} -j ACCEPT || true
      '';
    };
  in {
    packages.${system} = {
      default = nix-bitcoin.inputs.extra-container.lib.buildContainers {
        inherit system;
        legacyInstallDirs = true;

        config.imports = [
          containerMempool
          containerMempoolTor
        ];
      };
    };
  };
}
