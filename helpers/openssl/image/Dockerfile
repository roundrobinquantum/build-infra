FROM alpine:3.7

RUN apk add --update openssl && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/openssl"]