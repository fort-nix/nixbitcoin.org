[nix-bitcoin](https://github.com/fort-nix/nix-bitcoin/) configuration
for [nixbitcoin.org](https://nixbitcoin.org)

#### Requirements

[Nix](https://nixos.org/download.html) >= 2.9, with [flakes enabled](https://nixos.wiki/wiki/Flakes).

#### Usage

Run `nix develop` to enter a dev shell (defined in [`lib/dev-env.nix`](lib/dev-env.nix))
which provides deployment and development commands (like running the node in a container or VM).

You can also directly run a command like so:
```bash
nix develop -c <cmd>
nix develop -c help
nix develop -c deploy
```

`./run-test` runs the test. Requires root permissions because the test starts a container.

#### Branches

Branch `deployed` always contains the configuration that is currently deployed.

#### Deployment
To increase deployment speed, add a `ControlMaster` to your nixbitcoin.org config in `~/.ssh/config`:
```
Host nixbitcoin.org
# ...
ControlMaster auto
ControlPath /tmp/ssh-connection-%k
ControlPersist 5m
```

#### See also
- [`Initial deployment`](./deployment)
- [`maintenance.sh`](./maintenance/maintenance.sh)
