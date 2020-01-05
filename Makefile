# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.4.9-3
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

# Courtesy of: https://stackoverflow.com/a/49524393/3072002
# Common env variables (https://www.gnu.org/software/make/manual/make.html#index-_002eEXPORT_005fALL_005fVARIABLES)
.EXPORT_ALL_VARIABLES:
COMPOSE_PROJECT_NAME = krlb

.PHONY: test

test: wipe
	@docker-compose run lbe

trace: export TRACE=1
trace: test

build:
	@docker-compose build

wipe:
	@docker ps -aq | xargs -r docker rm -f > /dev/null