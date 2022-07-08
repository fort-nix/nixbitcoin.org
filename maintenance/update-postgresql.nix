baseSystemConfig:
rec {
  updatePostgresql = { pkgs, postgresqlOld, postgresqlNew }:
    pkgs.writers.writeBash "update-postgresql" ''
  set -euxo pipefail

  systemctl stop postgresql

  oldData="/var/lib/postgresql/${postgresqlOld.psqlSchema}"
  newData="/var/lib/postgresql/${postgresqlNew.psqlSchema}"
  oldBin="${postgresqlOld}/bin"
  newBin="${postgresqlNew}/bin"

  install -d -m 700 -o postgres -g postgres "$newData"
  cd "$newData"
  sudo -u postgres $newBin/initdb -D "$newData"

  sudo -u postgres $newBin/pg_upgrade \
    --old-datadir "$oldData" --new-datadir "$newData" \
    --old-bindir $oldBin --new-bindir $newBin \
    --jobs $(nproc) \
    --link \
    "$@"
'';

  # Todo: Use the main system here when we've switched to flake-based deployment
  base = baseSystemConfig;

  baseWithPostgresql = base.extendModules {
    modules = [{ services.postgresql.enable = true; }];
  };

  updateSystem = newSystemStateVersion:
    let
      baseNewStateVersion = baseWithPostgresql.extendModules {
        modules = [ ({ lib, ... }: {
          system.stateVersion = lib.mkForce newSystemStateVersion;
        })];
      };
    in
      updatePostgresql {
        pkgs = base.pkgs;
        postgresqlOld = baseWithPostgresql.config.services.postgresql.package;
        postgresqlNew = baseNewStateVersion.config.services.postgresql.package;
      };

  systemPostgresqlSchema = baseWithPostgresql.config.services.postgresql.package.psqlSchema;
}
