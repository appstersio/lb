FROM haproxy:2.0.1-alpine
LABEL maintainer="Pavel Tsurbeleu <krates@appsters.io>"

ENV STATS_PASSWORD=secret \
    PATH="/app/bin:${PATH}" \
    BUNDLER_VERSION=2.0.2 \
    BUNDLE_JOBS=16

RUN apk update && apk --update add bash tzdata ruby ruby-irb ruby-bigdecimal  \
    ruby-io-console ruby-json ruby-rake ca-certificates libssl1.1 openssl libstdc++ \
    ruby-webrick ruby-etc

ADD Gemfile /app/

RUN apk --update add --virtual build-dependencies ruby-dev build-base openssl-dev && \
    gem install bundler --version ${BUNDLER_VERSION} && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies

ADD . /app
ADD errors/* /etc/haproxy/errors/
EXPOSE 80 443
WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]
