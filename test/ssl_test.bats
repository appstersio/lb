#!/usr/bin/env bats

load "common"

setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services || true
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  sleep 3
}

@test "uses the certificate from SSL_CERTS" {
  run curl -s --cacert ./test/ssl/lb/cert.pem https://lb/a/

  [ "$status" -eq 0 ]
  [ "$output" = "service-a" ]
}

@test "uses the certificate from SSL_CERT_test1" {
  run curl -s --cacert ./test/ssl/test-1/cert.pem https://test-1/a/

  [ "$status" -eq 0 ]
  [ "$output" = "service-a" ]
}
