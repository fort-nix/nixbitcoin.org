{ config, lib, pkgs, ... }:

with lib;
let
  secretsDir = config.nix-bitcoin.secretsDir;
in
{
  services.zfs.autoSnapshot.enable = true;

  # Only use daily, weekly, monthly ZFS snapshots
  systemd.timers = {
    zfs-snapshot-frequent.enable = false;
    zfs-snapshot-hourly.enable = false;
    # The daily snapshot is run by borgbackup-job-main.service
    zfs-snapshot-daily.enable = false;
  };

  systemd.services.borgbackup-job-main = rec {
    requires = [ "zfs-snapshot-daily.service" ];
    after = requires;
  };

  programs.ssh.knownHosts."freak.seedhost.eu".publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBD2TmdE89ZD4XshcIcXZPLFC/nDxZdAr9yrH2/2OCNKEo/Ex60y8TQjp93isjdDj7Grf/GpW60OONfXTFe0r5iM=";

  services.borgbackup.jobs = {
    main = {
      startAt = "daily";

      preHook = ''
        latest_daily_snap=$(
          shopt -s nullglob
          printf '%s\n' /.zfs/snapshot/*daily* | tail -1
        )
        if [[ ! $latest_daily_snap ]]; then
          echo "Error: No daily snapshot found"
          exit 1
        fi
        echo "Using $latest_daily_snap"
        cd $latest_daily_snap
      '';

      paths = [ "var/lib" ];

      exclude = [
        "var/lib/bitcoind/blocks"
        "var/lib/bitcoind/chainstate"
        "var/lib/bitcoind/indexes"
        "var/lib/liquidd/*/blocks"
        "var/lib/liquidd/*/chainstate"
        "var/lib/liquidd/*/indexes"
        "var/lib/electrs"
        "var/lib/fulcrum"
        "var/lib/nbxplorer"
        "var/lib/duplicity"
        "var/lib/onion-addresses"

        "var/lib/i2pd"
        "var/lib/redis"
        "var/lib/udisks2"
        "var/lib/usbguard"

        "var/lib/acme"
        "var/lib/dovecot"
        "var/lib/dhparams" # from dovecot
        "var/lib/postfix"
        "var/lib/rspamd"

        "var/lib/machines"
        "var/lib/private"
        "var/lib/systemd"
      ];

      repo = "nixbitcoin@freak.seedhost.eu:borg-backup";
      doInit = false;
      encryption = {
        mode = "repokey";
        passCommand = "cat ${secretsDir}/backup-encryption-password";
      };
      environment = {
        BORG_RSH = "ssh -i ${secretsDir}/ssh-key-seedhost";
        # TODO-EXTERNAL: Use this definition when the borg job wrapper script
        # has been fixed in the borgbackup.nix NixOS module
        # BORG_REMOTE_PATH = "$HOME/.local/bin/borg";
        BORG_REMOTE_PATH = "/home34/nixbitcoin/.local/bin/borg";
      };
      compression = "zstd";
      extraCreateArgs = "--stats"; # Print stats after backup
      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 4;
        weekly = 2;
        monthly = 2;
      };
      # Compact (free repo storage space) every 7 days
      postPrune = ''
        if (( (($(date +%s) / 86400) % 7) == 0 )); then
          borg compact
        fi
      '';
    };
  };

  nix-bitcoin.secrets = {
    backup-encryption-password.user = "root";
    ssh-key-seedhost = {
      user = "root";
      permissions = "400";
    };
  };
  nix-bitcoin.generateSecretsCmds.backups = ''
     makePasswordSecret backup-encryption-password
     # Generate a dummy file so that setup-secrets doesn't fail
     touch ssh-key-seedhost
  '';

  # Use borg 1.2.1 (the latest 1.2.* release)
  # TODO-EXTERNAL: Remove this when 1.2.1 has landed in nixpkgs stable
  nixpkgs.overlays = [
    (_: _: { inherit (config.nix-bitcoin.pkgs.pkgsUnstable) borgbackup; })
  ];
}
