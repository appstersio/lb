#!/bin/bash
export COMPOSE_FILE=docker-compose.test.yml

etcdctl() {
	docker run --rm --net=host --entrypoint=/usr/bin/etcdctl lbtesthelper "$@"
}
curl() {
	docker run --rm --net=host -v $BATS_TEST_DIRNAME:/test --entrypoint=/usr/bin/curl lbtesthelper "$@"
}
config() {
	docker-compose exec lb cat /etc/haproxy/haproxy.cfg
}
sslscan() {
	docker run --rm --net=host nabz/docker-sslscan "$@"
}
lbe() {
  docker-compose exec lbe $@
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
