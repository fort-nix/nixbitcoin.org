## Deploy nixbitcoin.org on a Hetzner dedicated or cloud server

Deployment happens in three steps:
1. Boot a rescue system and kexec into a NixOS installer system.\
   This system has a known SSH host key.
2. Using the installer system, install a base system ([`../base.nix`](../base.nix)).\
   This is a minimal version of the main system
   ([`../configuration.nix`](../configuration.nix)) without public-facing services.
3. Deploy the main system using the standard deployment method.

These steps are implemented in: [`./deploy.sh`](./deploy.sh)

### Test deployment via a local VM

See [`./vm-deployment.sh`](./vm-deployment.sh)

## Backups

See [`./deploy-backup.sh`](./deploy-backup.sh)
