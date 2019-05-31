#!/usr/bin/env bats

load "common"

@test "does not configure haproxy to load certs when not configured with SSL_CERTS" {
  run config lb_no_health
  assert_output_contains "bind *:443 ssl crt /etc/haproxy/certs/" 0
  assert_output_contains "bind *:80" 1
}