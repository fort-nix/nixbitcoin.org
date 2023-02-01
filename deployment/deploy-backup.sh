# Run these commands on nixbitcoin.org

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# 1. Add pubkey auth to rsync.net

# This uses `programs.ssh` settings in ../backup.nix

ssh-keygen -y -f /var/src/secrets/ssh-key-backup > /tmp/authorized_keys
rsync --chmod=400 /tmp/authorized_keys rsync.net:.ssh/authorized_keys
rm /tmp/authorized_keys

# Set new passwd
ssh -t rsync.net passwd

# Test login
# Interactive login is unavailable on rsync.net
# Supported cmds: https://www.rsync.net/resources/howto/remote_commands.html
ssh rsync.net quota
ssh rsync.net borg1 --version

# Done. The borg repo is automatically initialized when the backup service
# (defined in ../backup.nix) runs.

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Debug: Manually init a repo

# Run the following commands in a nix shell
nix shell n#borgbackup

# Ensure borg version is >= 1.2.1
borg --version

export BORG_REPO=rsync.net:borg-backup
export BORG_REMOTE_PATH='borg1'
export BORG_PASSCOMMAND="cat /var/src/secrets/backup-encryption-password"
borg init --encryption=repokey --storage-quota=100G

debugCmds() {
    ssh rsync.net 'ls -alt'
    ssh rsync.net 'ls -al borg-backup'
    ssh rsync.net 'ls -al borg-backup/data'
    # Delete repo
    ssh rsync.net 'rm -rf borg-backup'

    # `borg-job-main` is defined by `services.borgbackup.jobs` in ../backup.nix
    borg-job-main info
    borg-job-main list
}
