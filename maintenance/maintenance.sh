# Commands useful for maintenance

ssh nixbitcoin.org

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
## Protocol for coordinating work on the server

# Before changing server state:
# 1. Show logged-in users
who
# 2. If there are other users logged in, notify them about the changes you're
# about to make.

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Systemd
systemctl status
systemctl list-jobs
systemctl list-units --failed

## Show messages messages with prio >= error since last boot
journalctl -b -p 3
# Exclude noisy services
journalctl -b -p 3 | egrep -v 'synapse|postfix|sshd'

## Show messages messages with prio >= warning since last boot
journalctl -b -p 4
journalctl -b -p 4 | egrep -v 'synapse|postfix|sshd'

journalctl -f

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# ZFS
zpool status
zfs list
# show useful stats
zfs list -o space,used,compressratio -t all
zfs get compressratio

# Create manual snapshot.
# This is useful before deploying a major NixOS upgrade.
zfs snapshot rpool/root@pre-update
# Delete snapshot
zfs destroy rpool/root@pre-update

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Access webinterfaces of RTL and btcpayserver via SSH
# This can be faster than using onion services.

# Start shell with SSH tunnels to services on nixbitcoin.org.
# The tunnels are automatically closed on shell exit.
systemd-run --user -u ssh-tunnels-nborg -tGd --setenv=PATH="$PATH" --setenv=SHLVL="$SHLVL" bash -c '
  ssh -N -L 10000:169.254.1.29:3000 -L 10001:169.254.1.24:23000 nixbitcoin.org&
  bash
'

# RTL
gpg --decrypt ../secrets/nixbitcoin.org/rtl-password.gpg 2>/dev/null
xdg-open http://localhost:10000
# btcpayserver
gpg --decrypt ../secrets/client-side/btcpayserver-credentials.gpg 2>/dev/null
xdg-open http://localhost:10001/btcpayserver

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Update postgresql database schema
# Required when the postgresql version is updated when changing `system.stateVersion`
# See also: https://nixos.org/manual/nixos/stable/index.html#module-services-postgres-upgrading

# The system state version that postgresql should be updated to
newSystemStateVersion=22.05

# Build script
drv=$(nix eval --raw ../deployment#lib --apply "lib: (lib.postgresql.updateSystem \"$newSystemStateVersion\").drvPath")
script=$(nix build --no-link --print-out-paths $drv)

# Check postgresql versions in script
# See also: https://www.postgresql.org/docs/current/pgupgrade.html
# By using option `--link` for `pg_upgrade`, db files are hardlinked when
# the datadir for the new schema is created
cat $script

# Run script
nix copy --to ssh://nixbitcoin.org $script
time ssh nixbitcoin.org $script

# Now change `system.stateVersion` to $newSystemStateVersion in ../base.nix and deploy

# Check postgresql
ssh nixbitcoin.org 'systemctl status postgresql'

# Run recommended analyzer script
schema=$(nix eval --raw ../deployment#lib.postgresql.systemPostgresqlSchema)
echo $schema
ssh nixbitcoin.org "sudo -u postgres /var/lib/postgresql/$schema/analyze_new_cluster.sh"

# Delete old data dir
ssh nixbitcoin.org "sudo -u postgres /var/lib/postgresql/$schema/delete_old_cluster.sh"

ssh nixbitcoin.org 'ls -al /var/lib/postgresql'

### Appendix
# The update step runs pretty fast (~10s)
# Example:
# Update the postgresql datadir from schema 11.1 to 14 (2022-07-02)
ssh nixbitcoin.org 'du -sh --apparent /var/lib/postgresql/11.1' # => 47G
# Duration:
# real 0m10.088s

ssh nixbitcoin.org 'ls -al /var/lib/postgresql'

# Undo migration (requires that postgresql was not run with the new datadir.)
ssh nixbitcoin.org 'mv /var/lib/postgresql/<schema>/global/pg_control{.old,}'
