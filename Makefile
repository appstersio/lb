# README: http://makefiletutorial.com
TARGET_PATH   = /src/app
VOLUME_PATH   = $(shell pwd):$(TARGET_PATH)
RUBY_IMAGE    = krates/toolbox:2.4.9-2
DOCKER_SOCKET = /var/run/docker.sock:/var/run/docker.sock

.PHONY: test

test:
	docker run -ti --rm --net=host --workdir $(TARGET_PATH) -v $(VOLUME_PATH) -v $(DOCKER_SOCKET) $(RUBY_IMAGE) \
		-c "bundle install && rspec spec/ && ./prepare_test.sh && bats test/"