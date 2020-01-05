# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.4.9-3
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

.PHONY: test

test: wipe
	@docker-compose run lbe

trace: export TRACE=1
trace: test

build:
	@docker-compose build

wipe:
	@docker ps -aq | xargs -r docker rm -f > /dev/null