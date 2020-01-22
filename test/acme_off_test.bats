#!/usr/bin/env bats

load "common"

@test "toggles off acme challenge server via ACME_OFF=y" {
  run curl -s -o /dev/null -I -w "%{http_code}" http://lb_no_acme/.well-known/acme-challenge/LoqXcYV8q5ONbJQxbmR7SCTNo3tiAXDfowyjxAjEuX0

  [ "$status" -eq 0 ]
  [ "$output" = "503" ]
}

@test "doesn't render acme settings in haproxy.cfg when ACME_OFF=y" {
  run docker-compose exec -T lb_no_acme cat /etc/haproxy/haproxy.cfg

  refute_line "acl acme_challenge path_beg /.well-known/acme-challenge/"
  refute_line "use_backend acme_challenge if acme_challenge"
  refute_line "backend acme_challenge"
}