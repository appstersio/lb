#!/bin/bash

config() {
	docker-compose exec -T lb cat /etc/haproxy/haproxy.cfg
}

# Some assert helpers, inspired by Dokku: https://github.com/dokku/dokku/blob/master/tests/unit/test_helper.bash
flunk() {
  { if [[ "$#" -eq 0 ]]; then cat -
    else echo "$*"
    fi
  }
  return 1
}

assert_equal() {
  if [[ "$1" != "$2" ]]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output_contains() {
  local input="$output"; local expected="$1"; local count="${2:-1}"; local found=0
  until [ "${input/$expected/}" = "$input" ]; do
    input="${input/$expected/}"
    let found+=1
  done
  assert_equal "$count" "$found"
}
