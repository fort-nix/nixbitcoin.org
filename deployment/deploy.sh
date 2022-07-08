#!/usr/bin/env bash

# Overview: See ./README.md

# Run this script by editing regions marked with `FIXME` and by manually
# executing sections in a shell.
# Unattended serial execution isn't yet implemented.

# Optional: Start building deployment dependencies in the background
runBuild() {
    systemd-run --user -u build --same-dir --setenv=PATH="$PATH" \
                nix build -L --out-link /tmp/deploy-nixbitcoinorg/links \
                .#packages.x86_64-linux.installerSystemKexec \
                .#packages.x86_64-linux.baseSystem
    # Check build status
    systemctl --user status build.service
}
runBuild

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Step 1: Boot a rescue system and kexec into a NixOS installer system
#
# This step requires >= 4 GB RAM on the deployment target.
# When deploying on a Hetzner cloud server, edit ../hardware.nix to import `hetznerCloud`

# Initial steps for Hetzner dedicated:
# - Enter Hetzner Robot
# - Rescue -> Activate Linux rescue system
#     Copy the SSH password
# - Reset -> Trigger automatic hardware reset
# - Rescue -> Show data of last activation (at the bottom)
#     It takes some time until the data show up.
#     Now copy the SSH host key fingerprints

source ./deployment-lib.sh

# FIXME: Set this to the server address
hostAddress=95.217.114.239
# Remove old entry from ~/.ssh/known_hosts
ssh-keygen -R $hostAddress

# Add SSH config
# FIXME: IMPORTANT: Manually add proxy commands if you don't want to directly
# connect to the server
echo "
Host nborg-installer
HostName $hostAddress
User root
ControlMaster auto
ControlPath /tmp/ssh-connection-%k
ControlPersist 1h" >> ~/.ssh/config

echo "
Host nixbitcoin.org
HostName $hostAddress
User root
ControlMaster auto
ControlPath /tmp/ssh-connection-%k
ControlPersist 1h" >> ~/.ssh/config

# Do the initial login.
# Check if the SSH host key fingerprint matches and enter 'yes'.
# Enter the password.
ssh nborg-installer :

deployInstallerSystem() {(
  set -euxo pipefail
  # Copy the kexec image to nborg-installer
  copyKexec
  # Run kexec to switch to the installer system
  ssh nborg-installer /tmp/kexec-boot
)}
deployInstallerSystem

# Wait until the new SSH fingerprint appears
# Expected fingerprint
ssh-keygen -lf <(ssh-keygen -yf <(gpg --decrypt ../secrets/client-side/ssh-host-key.gpg 2>/dev/null))
# Fetch actual fingerprint
ssh-keygen -lf <(ssh-keyscan nixbitcoin.org 2>/dev/null | grep -iw ed25519)

## Now the installer system has booted
# Remove old host key fingerprint from ~/.ssh/known_hosts
ssh-keygen -R $hostAddress
# Add the known installer system fingerprint
{ echo -n "$hostAddress "; ssh-keygen -y -f <(gpg --decrypt ../secrets/client-side/ssh-host-key.gpg 2>/dev/null); } >> ~/.ssh/known_hosts

# Check login
ssh nixbitcoin.org :

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Step 2: Install the base system

# Format storage
<2-format-storage.sh ssh nixbitcoin.org 'bash -s'
#
# Variant for testing on smaller servers: Override swapSize
# <2-format-storage.sh ssh nixbitcoin.org 'swapSize=1GiB bash -s'
#
# Remount already formatted storage
# <2-format-storage.sh ssh nixbitcoin.org 'bash -s remount'

# Determine and set `memorySizeGiB` in ../hardware.nix
ssh nixbitcoin.org free --gibi | awk '/Mem:/ { print $2 }'

# Optional: Generate config to update ../hardware.nix
makeConfig() {(
  set -euxo pipefail
  ssh nixbitcoin.org 'nixos-generate-config --root /mnt'
  ssh nixbitcoin.org 'cat /mnt/etc/nixos/hardware-configuration.nix'
  ssh nixbitcoin.org 'rm /mnt/etc/nixos/*'
)}
# makeConfig

deployBaseSystem() {(
  set -euxo pipefail
  nix build .#packages.x86_64-linux.baseSystem --out-link /tmp/deploy-nixbitcoinorg/base-system
  nix copy --to ssh://nixbitcoin.org /tmp/deploy-nixbitcoinorg/base-system
  ssh nixbitcoin.org "nixos-install --system $(realpath /tmp/deploy-nixbitcoinorg/base-system) --root /mnt --no-root-passwd"
  # Deploy SSH host key
  gpg --decrypt ../secrets/client-side/ssh-host-key.gpg 2>/dev/null | \
    ssh nixbitcoin.org 'install -m 600 <(cat) /mnt/etc/ssh/ssh_host_ed25519_key'
)}
deployBaseSystem

# Reboot
ssh -n nixbitcoin.org '{ sleep 0.2; reboot; } &>/dev/null &'
# Close ControlMaster
ssh nixbitcoin.org -O exit

# Check login
ssh nixbitcoin.org :

rm -rf /tmp/deploy-nixbitcoinorg
# Now delete/edit entries in ~/.ssh/config

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Optional: Restore backups

## Variant 1: Restore /var/lib from another system
ssh nixbitcoin.org 'rsync -ahz --info=progress2 backup-server:/temp/var/lib/ /var/lib --exclude=/systemd'

## Variant 2: Restore /var/lib from backup
# TODO: Streamline this deployment step when switching to flakes for the main system deployment

# Copy backup-related secrets
gpg --decrypt ../secrets/nixbitcoin.org/backup-encryption-password.gpg 2>/dev/null | \
    ssh nixbitcoin.org 'install -D -m 600 <(cat) /var/src/secrets/backup-encryption-password'
gpg --decrypt ../secrets/nixbitcoin.org/ssh-key-seedhost.gpg 2>/dev/null | \
    ssh nixbitcoin.org 'install -D -m 600 <(cat) /var/src/secrets/ssh-key-seedhost'

deployBaseSystemWithBackups() {(
  set -euxo pipefail
  nix build .#packages.x86_64-linux.baseSystemWithBackups --out-link /tmp/deploy-nixbitcoinorg/system
  nix copy --to ssh://nixbitcoin.org /tmp/deploy-nixbitcoinorg/system
  ssh -n nixbitcoin.org "$(realpath /tmp/deploy-nixbitcoinorg/system)/bin/switch-to-configuration switch"
)}
deployBaseSystemWithBackups

# List backups
ssh nixbitcoin.org borg-job-main list
# Show last backup
ssh nixbitcoin.org 'borg-job-main info ::$(borg-job-main list --short | tail -1)'

# Restore last backup
# As of 2022-07-01, the latest backup had a compressed size of 19.02 GB (54.79 GB uncompressed).
# Restoring from seedhost took 6m33.127s.
ssh nixbitcoin.org bash -s <<'EOF'
tmux new -d -s restore-backup 'cd / && time borg-job-main extract --progress ::$(borg-job-main list --short | tail -1); sleep infinity'
EOF

# Check progress. Close terminal or press 'Ctrl+b d' to detach
ssh -t nixbitcoin.org 'tmux attach'

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Step 3: Install main system
nix-shell ..src/shell.nix --run deploy

# Now update njalla DNS entries
