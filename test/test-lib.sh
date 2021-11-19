burstLimitIgnoreInternalResponse=

getBurstLimit() {
  type=$1
  url=$2
  max=100

  if [[ $type == GET ]]; then
    okStatus=200
    curlArgs=()
  else
    # POST
    okStatus=302
    curlArgs=(-X POST -d '')
  fi

  for ((i=0; i<$max; i++)); do
    status=$(getStatusCode "${curlArgs[@]}" "$url")
    if [[ $status != $okStatus ]]; then
      if [[ $status == 429 ]]; then
        echo $i
        return
      elif [[ ! $burstLimitIgnoreInternalResponse ]]; then
        >&2 echo "Unexpected status code ($status) for $url"
        return 1
      fi
    fi
  done
  >&2 echo "Max burst limit ($max) exceeded for $url"
  return 1
}

getStatusCode() {
  maxTime=
  if [[ $burstLimitIgnoreInternalResponse ]]; then
    maxTime="--max-time 0.02"
  fi
  curl -s $maxTime -o /dev/null -w "%{http_code}" "$@"
}

assertBurstLimit() {
  expected=$1
  type=$2
  url=$3
  actual=$(getBurstLimit "$type" "$url")
  tolerance=8
  if ((actual < expected || actual - expected > tolerance)); then
    >&2 echo "Unexpected burst limit: $actual. Expected: $expected ($type $url)"
    return 1
  fi
}

assertMatches() {
  expected="$1"
  actual="$2"
  if [[ $actual != $expected ]]; then
    echo
    echo 'Pattern does not match'
    echo 'Expected:'
    echo "$expected"
    echo
    echo 'Actual:'
    echo "$actual"
    echo
    return 1
  fi
}

waitForPort() {
  address=$1
  port=$2
  attempts=200
  while ! { exec 3>/dev/tcp/$address/$port && exec 3>&-; } &>/dev/null; do
    ((attempts-- == 0)) && { echo "Error: $address:$port is unreachable"; exit 1; }
    sleep 0.01
  done
}

restartNginx() {
  # Run `reset-failed` to reset service restart counters.
  # This avoids error `start-limit-hit` after many restarts
  c bash -c 'systemctl restart nginx && systemctl reset-failed nginx'
  waitForPort $ip 80
}

WANStatus=
isWANenabled() {
  if [[ ! $WANStatus ]]; then
    if c bash -c '[[ $WANEnabled ]]'; then
      WANStatus=1
    else
      WANStatus=0
    fi
  fi
  [[ $WANStatus == 1 ]]
}

btcpCurl() {
  method=$1
  shift
  curl -sS -H "Content-Type: application/json" --user "a@a.a:aaaaaa" \
       "$@" "$ip:23000/btcpayserver/api/v1/$method" | jq
}

btcpAPI() {
  type=$1
  method=$2
  shift
  shift
  if [[ $type == get ]]; then
    btcpCurl $method -X get "$@"
  else
    body=$3
    shift
    btcpCurl $method -X post -d "$body"
  fi
}
