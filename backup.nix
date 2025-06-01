{ config, lib, pkgs, ... }:

with lib;
let
  secretsDir = config.nix-bitcoin.secretsDir;
in
{
  services.zfs.autoSnapshot = {
    enable = true;
    daily = 1;
  };

  # Don't auto-run snapshots
  systemd.timers = {
    zfs-snapshot-frequent.enable = false;
    zfs-snapshot-hourly.enable = false;
    zfs-snapshot-daily.enable = false;
    zfs-snapshot-monthly.enable = false;
    zfs-snapshot-weekly.enable = false;
  };

  systemd.services.borgbackup-job-main = rec {
    requires = [ "zfs-snapshot-daily.service" ];
    after = requires;
  };

  programs.ssh = {
    knownHosts."zh2896.rsync.net".publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLR2uz+YLn2KiQK0Luu8rhfWS6LHgUfGAWB1j8rM2MKn4KZ2/LhIX1CYkPKMTPxHr6mzayeL1T1hyJIylxXv0BY=";
    extraConfig = ''
      Host rsync.net
      HostName zh2896.rsync.net
      User zh2896
      IdentityFile /var/src/secrets/ssh-key-backup
    '';
  };

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
        "var/lib/containers"
        # Exclude matrix-synapse
        "var/lib/postgresql/${config.services.postgresql.package.psqlSchema}/base/16403"
        # Only contains mempool
        "var/lib/mysql"

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

      repo = "rsync.net:borg-backup";
      encryption = {
        mode = "repokey";
        passCommand = "cat ${secretsDir}/backup-encryption-password";
      };
      environment = {
        BORG_REMOTE_PATH = "borg1";
      };
      compression = "zstd";
      extraCreateArgs = "--stats"; # Print stats after backup
      extraInitArgs = "--storage-quota=100G";
      # prune.keep = {
      #   within = "1d"; # Keep all archives from the last day
      #   daily = 4;
      #   weekly = 2;
      #   monthly = 2;
      # };
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
    ssh-key-backup = {
      user = "root";
      permissions = "400";
    };
  };
  nix-bitcoin.generateSecretsCmds.backups = ''
     makePasswordSecret backup-encryption-password
     # Generate a dummy file so that setup-secrets doesn't fail
     touch ssh-key-backup
  '';
}
