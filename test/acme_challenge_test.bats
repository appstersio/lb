#!/usr/bin/env bats

load "common"

setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services || true
}

@test "uses the challenges from ACME_CHALLENGE_*" {
  run curl -s http://lb/.well-known/acme-challenge/LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0

  [ "$status" -eq 0 ]
  [ "$output" = "LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0.9jg46WB3rR_AHD-EBXdN7cBkH1WOu0tA3M9fm21mqTI" ]
}
