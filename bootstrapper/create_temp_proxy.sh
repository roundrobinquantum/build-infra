#!/bin/bash

set -e

HOST_IP=$(ip route get 1 | awk '{print $NF;exit}')

docker build -t temp-nginx --build-arg HOST_IP=${HOST_IP} .
docker run --rm --name temp-nginx -d -p 80:80 temp-nginx

docker tag temp-nginx mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap
docker push mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap

docker rm -fv temp-nginx
docker rmi temp-nginx