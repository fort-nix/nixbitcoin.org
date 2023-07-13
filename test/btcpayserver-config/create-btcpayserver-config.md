# Create and export a btcpayserver test config

This config is required to host the website donation page on a test node.

These instructions have been tested with btcpayserver version v1.10.4.


## 1. Start container shell

```sh
nix develop -c container website
```

## 2. Configure btcpayserver

### 2.1 Automated settings
Run the following in the container shell to create a user
(email: `a@a.a`, password: `aaaaaa`) and a store named `donations`.

```bash
call_api() {
   curl -sS -H "Content-Type: application/json" -X post --user "a@a.a:aaaaaa"  -d "$2" "$ip:23000/btcpayserver/api/v1/$1" | jq
}
call_api users '{"email": "a@a.a", "password": "aaaaaa", "isAdministrator": true}'
call_api stores '{"name": "donations"}'
```

### 2.2 Manual settings via the web interface

Run the following in the container shell to open the web interface
```sh
runuser -u $(logname) -- xdg-open http://$ip:23000/btcpayserver
```

### Manual settings

1. Configure Wallets:
- Left menu: Wallets -> Bitcoin
  - Setup: Create hot wallets for BTC, LBTC (Liquid)
- Left menu: Wallets -> Lightning
  - 'Use internal node', Save
  - Settings:
    - Description template of the lightning invoice: "nix-bitcoin donation"
    - Enable LNURL: On
    - LNURL Classic Mode: On
  - Save

2. Create Apps
- Left menu: Plugins -> 'Point of Sale' -> Name: 'donate'
  - Display Title: Donate
  - Manually remove all products
  - 'User can input custom amount': On
  - Save
- Left menu: Plugins -> Lightning Address -> Add Address
  - Username: donate
  - Save


## 4. Save data
Run the following in the container shell
```bash
mkdir -p ./data/data-dir
c systemctl stop btcpayserver

# Export db
c runuser -u postgres -- pg_dump -C btcpaydb > data/db.sql

# Copy login cookie
# This fixed login cookie is valid in all btcpayserver instances
rsync -a /var/lib/nixos-containers/nb-test/var/lib/btcpayserver/*.xml data/data-dir

# Exit container shell
exit

sudo chown $USER: -R data

# Bump up login cookie expiration date
sed -i 's|<expirationDate>.*|<expirationDate>2100-01-01T00:00:00.0000000Z</expirationDate>|' data/data-dir/*
```
