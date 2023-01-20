#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Deploy on nixbitcoin.org
mempool_container=$(nix build --no-link --print-out-paths) && nix copy $mempool_container --to ssh://nixbitcoin.org && ssh nixbitcoin.org "ln -sfn $mempool_container /tmp/mempool_container"

ssh nixbitcoin.org
# Now continue at 'Start/update container' below

https://mempool-debug.nixbitcoin.org/
https://mempool-debug-tor.nixbitcoin.org/

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Deploy locally in container

# Build mempool container.
# If nixbitcoin.org container is already running, link the mempool container to
# the nixbitcoin.org container
mempool_container=$(nix build --no-link --print-out-paths) && if sudo systemctl is-active --quiet container@nb-test; then echo 'linking'; extra-container run nb-test -- ln -sfn $mempool_container /tmp/mempool_container; fi
echo $mempool_container

# Start nixbitcoin.org container
container withWAN --run c bash -c "ln -s $mempool_container /tmp/mempool_container && bash"

# Start mempool container inside nixbitcoin.org container
# This works when only one container is defined
extra-container shell /tmp/mempool_container

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Start/update container
extra-container create -s -u /tmp/mempool_container
extra-container destroy /tmp/mempool_container
nixos-container root-login mempool
function c () { nixos-container run mempool -- "$@" | cat; }
function c () { nixos-container run mempool-tor -- "$@" | cat; }

# Debug mempool container
c journalctl -u mempool
c systemctl status mempool
c systemctl status bitcoind
c systemctl status
c bitcoin-cli -getinfo
c ls -al /etc/nix-bitcoin-secrets
c ls -al /host-secrets
c findmnt
c systemctl status setup-secrets
c curl example.com

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# Debug mempool service
# Query mempool backend
nixos-container run mempool -- curl http://localhost:8999/api/v1/blocks/1 | jq
curl http://10.10.0.2:8999/api/v1/blocks/1 | jq
nixos-container run mempool -- curl http://localhost:8999/api/v1/address/1CGG9qVq2P6F7fo6sZExvNq99Jv2GDpaLE | jq
# Query fulcrum
echo '{"method": "server.version", "id": 0 }' | nixos-container run mempool -- nc 169.254.1.31 50011 | head -1 | jq

# Query via webserver
curl -fsS -H "Host: mempool-debug.nixbitcoin.org" 169.254.1.21
curl -fsS -H "Host: mempool-debug.nixbitcoin.org" http://169.254.1.21/api/v1/blocks/tip/height | jq
curl -fsS -H "Host: mempool-debug.nixbitcoin.org" http://169.254.1.21/api/v1/blocks/1 | jq
curl -fsS -H "Host: mempool-debug.nixbitcoin.org" http://169.254.1.21/api/address/1CGG9qVq2P6F7fo6sZExvNq99Jv2GDpaLE | jq

curl -fsS -H "Host: mempool-debug-tor.nixbitcoin.org" 169.254.1.21
curl -fsS -H "Host: mempool-debug-tor.nixbitcoin.org" http://169.254.1.21/api/v1/blocks/tip/height | jq
curl -fsS -H "Host: mempool-debug-tor.nixbitcoin.org" http://169.254.1.21/api/v1/blocks/1 | jq
curl -fsS -H "Host: mempool-debug-tor.nixbitcoin.org" http://169.254.1.21/api/address/1CGG9qVq2P6F7fo6sZExvNq99Jv2GDpaLE | jq

# Locally, over SSL. Only works on nixbitcoin.org
curl -k -fsS -H "Host: mempool-debug-tor.nixbitcoin.org" https://169.254.1.21/api/v1/blocks/tip/height | jq

# From WAN
curl -fsS https://mempool-debug-tor.nixbitcoin.org/api/v1/blocks/tip/height | jq
curl -fsS https://mempool-debug.nixbitcoin.org/api/v1/blocks/tip/height | jq

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# todo
# on server:
rm /var/cache/nginx/mempool-api-debug /var/cache/nginx/mempool-api-debug-tor
