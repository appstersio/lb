#!/usr/bin/env bats

load "common"


setup() {
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-a || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-b || true
  etcdctl rm --recursive /kontena/haproxy/lb/services/service-c || true
}


@test "supports virtual_hosts" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.foo.com,api.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  sleep 1
  run curl -s -H "Host: www.foo.com" http://lb/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: api.foo.com" http://lb/
  [ "${lines[0]}" = "service-b" ]
}

@test "supports wildcard virtual_hosts" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts *.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292
  sleep 1
  run curl -s -H "Host: www.foo.com" http://lb/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: api.foo.com" http://lb/
  [ "${lines[0]}" = "service-b" ]
  run curl -s -H "Host: www.bar.com" http://lb/
  [ "${lines[0]}" = "service-c" ]
}

@test "supports virtual_hosts + virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /b
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com,api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://lb
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s http://lb/b
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: www.bar.com" http://lb/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]

  run curl -s -H "Host: api.bar.com" http://lb/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "supports virtual_hosts + virtual_path + keep_virtual_path" {
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.foo.com
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /virtual_path
  etcdctl set /kontena/haproxy/lb/services/service-a/keep_virtual_path "true"
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_path /b
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com,api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://lb
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: www.foo.com" http://lb/virtual_path
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-a" ]
  [ "${lines[1]}" = "/virtual_path" ]

  run curl -s http://lb/b
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
  [ "${lines[1]}" = "" ]

  run curl -s -H "Host: www.bar.com" http://lb/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]

  run curl -s -H "Host: api.bar.com" http://lb/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "handles empty upstreams" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s -H "Host: www.bar.com" http://lb
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: api.bar.com" http://lb/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "on duplicate virtual_hosts first one in alphabets wins" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://lb
  [ "$status" -eq 0 ]
  [ $(expr "$output" : ".*Service Unavailable.*") -ne 0 ]

  run curl -s -H "Host: www.bar.com" http://lb/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
}

@test "prioritizes first vhost+vpath, then vhost and finally vpath" {
  etcdctl set /kontena/haproxy/lb/services/service-a/virtual_path /
  etcdctl set /kontena/haproxy/lb/services/service-a/upstreams/server service-a:9292

  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_hosts api.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-c/virtual_path /c
  etcdctl set /kontena/haproxy/lb/services/service-c/upstreams/server service-c:9292

  sleep 1
  run curl -s http://lb
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-a" ]

  run curl -s -H "Host: www.bar.com" http://lb/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: api.bar.com" http://lb/c
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-c" ]
}

@test "works with domain:port host header" {
  etcdctl set /kontena/haproxy/lb/services/service-b/virtual_hosts www.bar.com
  etcdctl set /kontena/haproxy/lb/services/service-b/upstreams/server service-b:9292

  sleep 1

  run curl -s -H "Host: www.bar.com" http://lb/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]

  run curl -s -H "Host: www.bar.com:80" http://lb/
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "service-b" ]
}
