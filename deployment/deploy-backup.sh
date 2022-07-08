##
## Warning: This is a very rough sketch
##

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# 1. Deploy borg binary on seedhost

TMPDIR=$(mktemp -d)
export GNUPGHOME=$TMPDIR

# fetch dev key (tw@waldmann-edv.de)
gpg --recv-keys --keyserver hkps://keyserver.ubuntu.com 9F88FB52FAF7B393

# Download `linuxold` release which is compatible with the glibc version on seedhost
curl -L https://github.com/borgbackup/borg/releases/download/1.2.1/borg-linuxold64 -O
curl -L https://github.com/borgbackup/borg/releases/download/1.2.1/borg-linuxold64.asc -O
gpg --verify borg-linuxold64.asc

rm -rf $TMPDIR

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# 2. Init borg backup repo on seedhost

# Run the following commands in a nix shell
nix shell nixpkgs/29399e5ad1660668b61247c99894fc2fb97b4e74#borgbackup

# Ensure borg version is >= 1.2.1
borg --version

if [[ ! $XDG_RUNTIME_DIR ]]; then
    echo 'Error: Missing env var XDG_RUNTIME_DIR'
    return 1
fi
export secrets=$XDG_RUNTIME_DIR/borg-secrets
mkdir -p $secrets
install -m 600 <(gpg --decrypt ../secrets/nixbitcoin.org/ssh-key-seedhost.gpg) $secrets/ssh-key-seedhost
install -m 600 <(gpg --decrypt ../secrets/nixbitcoin.org/backup-encryption-password.gpg) $secrets/backup-encryption-password

export BORG_REPO=nixbitcoin@freak.seedhost.eu:borg-backup
export BORG_RSH="ssh -i $secrets/ssh-key-seedhost"
export BORG_REMOTE_PATH='$HOME/.local/bin/borg'
export BORG_PASSCOMMAND="cat $secrets/backup-encryption-password"
borg init --encryption=repokey --storage-quota=400G

debugCmds() {
    borg info

    ssh freak.seedhost.eu 'ls -alt'
    ssh freak.seedhost.eu 'ls -al borg-backup'
    ssh freak.seedhost.eu 'ls -al borg-backup/data'
    # Delete repo
    ssh freak.seedhost.eu 'rm -rf borg-backup'

    # This can be run on nixbitoin.org to manage the backup
    borg-job-main ...
    borg-job-main list
}

rm -rf $secrets
