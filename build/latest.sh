#!/bin/bash

if [ ! -z "$TRAVIS_TAG" ] && [ ! -z "$DOCKER_PASSWORD" ]; then
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
    TAG=${TRAVIS_TAG/v/}
    docker build -t krates/lb:latest -t "krates/lb:$TAG" .
    docker push "krates/lb:$TAG"
    docker push krates/lb:latest
fi