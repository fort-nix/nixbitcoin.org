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

# Open btcpayserver admin interface. Mail: a@a Password: aaaaaaa
runuser -u $(logname) -- xdg-open http://$ip:23000/btcpayserver

# Open donation page in browser
runuser -u $(logname) -- xdg-open http://$ip/donate

# Create invoice
curl -v -L -X POST -d '' $ip/donate

source ./test-lib.sh
# Show invoices
btcpAPI get stores/$(btcpAPI get stores | jq -r '.[].id')/invoices
