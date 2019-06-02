FROM haproxy:1.9.4-alpine
LABEL maintainer="Pavel Tsurbeleu <pavel.tsurbeleu@me.com>"

ENV STATS_PASSWORD=secret \
    PATH="/app/bin:${PATH}"

RUN apk update && apk --update add bash tzdata ruby ruby-irb ruby-bigdecimal  \
    ruby-io-console ruby-json ruby-rake ca-certificates libssl1.1 openssl libstdc++ \
    ruby-webrick ruby-etc

ADD Gemfile /app/

RUN apk --update add --virtual build-dependencies ruby-dev build-base openssl-dev && \
    gem install bundler --no-ri --no-rdoc && \
    cd /app ; bundle install --without development test && \
    apk del build-dependencies

ADD bin /app/bin/
ADD lib /app/lib/
ADD entrypoint.sh /app/
ADD README.md /app/


ADD errors/* /etc/haproxy/errors/

EXPOSE 80 443
WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]
