[nix-bitcoin](https://github.com/fort-nix/nix-bitcoin/) configuration
for [nixbitcoin.org](https://nixbitcoin.org)

#### Highlights:
- A proof of concept [donation page](https://nixbitcoin.org/donate) ([src](./website/donate/default.nix)) with payment methods:
  - LNURL ([LUD-06](https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md)
    and [LUD-16](https://github.com/fiatjaf/lnurl-rfc/blob/luds/16.md)/[Lightning Address](https://lightningaddress.com/))
  - Lightning (bolt11)
  - Bitcoin on-chain
  - Liquid on-chain
- Matrix Synapse homeserver ([src](./matrix.nix)) with email registrations
  via a self-hosted [mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver).

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
ControlPath /tmp/ssh-connection-%r@%k-%p
ControlPersist 5m
```

#### See also
- [`Initial deployment`](./deployment)
- [`maintenance.sh`](./maintenance/maintenance.sh)
