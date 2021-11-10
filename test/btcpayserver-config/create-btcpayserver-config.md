# Create and export a btcpayserver test config

This config is required to host a website donation page on a test node.

These instructions have been tested with btcpayserver version v1.3.1.


## 1. Start container shell

```sh
nix-shell ../../shell.nix --command container
```

## 2. Configure btcpayserver

### 2.1 Automated settings
Run the following in the container shell to create a user
(email: `a@a.a`, password: `aaaaaa`) and a store named `nix-bitcoin`.

```bash
post() {
   curl -sS -H "Content-Type: application/json" -X post --user "a@a.a:aaaaaa"  -d "$2" "$ip:23000/btcpayserver/api/v1/$1" | jq
}
post users '{"email": "a@a.a", "password": "aaaaaa", "isAdministrator": true}'
post stores '{"name": "nix-bitcoin"}'
```

### 2.2 Manual settings via the web interface

Run the following in the container shell to open the web interface
```sh
runuser -u $SUDO_USER -- xdg-open http://$ip:23000/btcpayserver
```

### Manual settings

1. Configure Store:
- Stores -> nix-bitcoin -> Settings
  - Section `Wallet`
    BTC, LBTC -> Setup: Create hot wallets for BTC, LBTC
  - Section `Lightning`
    - BTC -> Setup: Choose internal node for for BTC
    - BTC -> Settings -> Enable lnurl

2. Create Apps
- Store: 'nix-bitcoin', App type: 'Point of sale', Name: 'donate'
  - Display Title: Donate
  - Manually remove all products
  - Save
- Store: 'nix-bitcoin', App type: 'Point of sale', Name: 'donate_lnurl'
  - Display Title: Donate
  - Manually remove all products
  - Create a single product
    - Title: Donate
    - Price: Custom
  - Point of Sale Style: Print
  - Save


## 4. Save data
Run the following in the container shell
```bash
mkdir -p data/data-dir
c systemctl stop btcpayserver

# Export db
c runuser -u postgres -- pg_dump -C btcpaydb > data/db.sql

# Copy login cookie
# This fixed login cookie is valid in all btcpayserver instances
rsync -a /var/lib/containers/nb-test/var/lib/btcpayserver/*.xml data/data-dir

# Exit container shell
exit

sudo chown $USER: -R data

# Bump up login cookie expiration date
sed -i 's|<expirationDate>.*|<expirationDate>2100-01-01T00:00:00.0000000Z</expirationDate>|' data/data-dir/*
```
