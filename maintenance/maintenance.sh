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
