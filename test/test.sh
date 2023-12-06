#!/usr/bin/env bash
set -euo pipefail

# This script is run in a container shell by
# ./cmds/run-test

# To manually run (parts of) the test, start the nix shell of this project, run
# `container website` or `co website` and execute test commands in the container shell.

cd "${BASH_SOURCE[0]%/*}"
source ./test-lib.sh

trap 'echo "Error at ${BASH_SOURCE[0]}:$LINENO"' ERR

echo -n "Wait until btcpayserver serves content..."
while [[ $(getStatusCode http://$ip/donate) != 200 ]]; do
  sleep 0.1
done
echo "Done"

echo "Test rate limits"
assertBurstLimit 20 GET http://$ip
restartNginx # Reset rate limit counters
assertBurstLimit 20 GET http://$ip/donate
restartNginx

if isWANenabled; then
  echo "Running tests in online mode"
else
  # For the following invoice-generating requests, btcpayserver
  # requires an internet connection for rate-fetching (even for the
  # Bitcoin-only LNURL invoice).
  # Set this variable to ignore the btcpayserver failure and just check for the
  # nginx-generated status code (429) that indicates active rate limiting.
  burstLimitIgnoreInternalResponse=1
fi

assertBurstLimit 5 POST http://$ip/donate/test-rate-limit
restartNginx

echo "Success"
