FROM mpl-dockerhub.hepsiburada.com/alpine:3.7

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/curl"]