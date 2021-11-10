[nix-bitcoin](https://github.com/fort-nix/nix-bitcoin/) configuration
for [nixbitcoin.org](https://nixbitcoin.org)

Run `nix-shell` to enter a dev shell ([`shell.nix`](./shell.nix)) which provides
commands for running the node in a container or VM.

### Highlights:
- A proof of concept [donation page](https://nixbitcoin.org/donate) ([src](./website/donate/default.nix)) with payment methods:
  - LNURL ([LUD-06](https://github.com/fiatjaf/lnurl-rfc/blob/luds/06.md)
    and [LUD-16](https://github.com/fiatjaf/lnurl-rfc/blob/luds/16.md)/[Lightning Address](https://lightningaddress.com/)),
  - bolt11
  - Bitcoin on-chain
  - Liquid on-chain
- A Matrix synapse homeserver ([src](./matrix.nix)) with email registrations via a self-hosted [mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver).
