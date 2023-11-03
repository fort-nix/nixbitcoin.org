#!/usr/bin/env bash
set -euo pipefail

# Call make-donation-page.py, print and save its output.
# Cache python environment for fast testing cycles.

cd "${BASH_SOURCE[0]%/*}"

# Hash of build dependencies
hash=$(
  {
    echo "$NIX_PATH"
    cat make-donation-page.nix python-packages.nix
  } | sha1sum | cut -f1 -d' '
)

cachePrefix=/tmp/nixbitcoinorg-donate
cachedEnv=$cachePrefix-$hash
if [[ ! -e $cachedEnv ]]; then
  rm -f $cachePrefix-*
  nix-build --out-link $cachedEnv make-donation-page.nix -A python >/dev/null
fi

args='{
  "lnurl_plaintext": "https://nixbitcoin.org/donate/lightning",
  "lightning_address": "test@nixbitcoin.org",
  "root_url": "http://10.225.255.2",
  "btcpayserver_app_id": "btcpappid",
  "html_template": "site/donate-template.html",
  "output_file": "site/donate.htm"
}'
ARGS="$args" $cachedEnv/bin/python make-donation-page.py
