#!/bin/bash

# etcdctl manual: https://github.com/etcd-io/etcd/tree/master/etcdctl#etcdctl
# BASH Guide: 9.1 Internal Variables (http://tldp.org/LDP/abs/html/internalvariables.html)

config() {
  # Find out more here: https://www.computerhope.com/unix/nc.htm
	printf "cat /etc/haproxy/haproxy.cfg" | nc $1 9999
}

ssl_certs() {
  printf "ls /etc/haproxy/certs" | nc $1 9999
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