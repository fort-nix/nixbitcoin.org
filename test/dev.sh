### Commands and snippets for testing and exploring the node config
# Run these from within the nix-shell (nix-shell ../shell.nix)

# The main test suite. Runs offline.
# Starts a fully-featured node, checks that all
# systemd units succeed at startup and runs ./test.sh
run-test

# Runs ./test.sh in fast node config that only includes the website.
# Also includes online tests.
run-test --website


### Website
## Run the following commands in a container shell:
co website

curl $ip
lynx -dump $ip
lynx -dump $ip/donate
lynx -dump $ip/donate/other

# Create invoice via LNURL
curl -sS $ip/donate/lightning | jq

# Create invoice via catch-all Lightning Address *@nixbitcoin.org
curl -sS $ip/.well-known/lnurlp/donate | jq
curl -sS $ip/.well-known/lnurlp/foo | jq

# Create Lightning invoice via LNURL. (Not functional in regtest.)
curl -sS $(curl -sS $ip/donate/lightning | jq -r .callback)?amount=1000 | jq

# Create invoice via other methods
curl -v -L -X POST -d '' $ip/donate/other

source ./test-lib.sh
# Show invoices
btcpAPI get stores/$(btcpAPI get stores | jq -r '.[].id')/invoices

# Open donation page in browser
runuser -u $(logname) -- xdg-open http://$ip/donate

# Open btcpayserver admin interface. Mail: a@a Password: aaaaaaa
runuser -u $(logname) -- xdg-open http://$ip:23000/btcpayserver
