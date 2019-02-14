#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "returns health check page if configured in env" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_hosts www.foo.com
  sleep 1
  run lbe curl -s http://localhost/health
  [ $(expr "$output" : ".*Everything seems to be 200 - OK.*") -ne 0 ]
}

@test "returns error if health not configured in env" {
  etcdctl set /kontena/haproxy/lb_no_health/services/service-a/virtual_hosts www.foo.com
  sleep 1
  run curl -s http://localhost:8181/health/
  [ $(expr "$output" : ".*503 — Service Unavailable.*") -ne 0 ]
}

@test "supports health check uri setting for balanced service" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/health_check_uri /health
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run lbe curl -k -s https://localhost/a/
  [ "${lines[0]}" = "service-a" ]

  run config
  assert_output_contains "option httpchk GET /health"

}


@test "supports health check port setting for balanced service" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /a/
  etcdctl set /kontena/haproxy/lb/services/service-a/health_check_uri /health
  etcdctl set /kontena/haproxy/lb/services/service-a/health_check_port 9292
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292
  sleep 1
  run lbe curl -k -s https://localhost/a/
  [ "${lines[0]}" = "service-a" ]

  run config
  assert_output_contains "option httpchk GET /health"
  assert_output_contains "server server service-a:9292 check port 9292"

}
