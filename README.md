[nix-bitcoin](https://github.com/fort-nix/nix-bitcoin/) configuration
for [nixbitcoin.org](https://nixbitcoin.org)

Run `nix-shell` to enter a dev shell ([`shell.nix`](./shell.nix)) which provides
commands for running the node in a container or VM.

`./run-test` runs the test. Requires root permissions because the test starts a container.

#### See also
- [`Deployment`](./deployment)
- [`maintenance.sh`](./maintenance/maintenance.sh)
