#!/usr/bin/env bats

load "common"

@test "ciphers are set" {
  echo "$(sslscan lb | xargs -L 1 echo '#')" >&3
  echo '#' >&3

  run sslscan lb
  assert_output_contains "ECDHE-RSA-AES128-GCM-SHA256" 1
  assert_output_contains "ECDHE-ECDSA-AES128-GCM-SHA256" 0
}
