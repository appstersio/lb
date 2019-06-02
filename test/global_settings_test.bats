#!/usr/bin/env bats

load "common"

@test "supports custom global settings via env" {

  run config lb
  assert_output_contains "ssl-default-bind-options force-tlsv12"

}
