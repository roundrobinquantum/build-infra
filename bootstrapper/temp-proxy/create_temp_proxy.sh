#!/bin/bash

set -e

function build_and_run_temp_nginx() {
  echo "bootstrap => Finding host machine ip"
  HOST_IP=$(ip route get 1 | awk '{print $NF;exit}')
  echo "bootstrap => Host ip is : ${HOST_IP}"

  echo "bootstrap => Creating a temp nginx"
  docker build -t temp-nginx --build-arg HOST_IP=${HOST_IP} .
  docker run --rm --name temp-nginx -d -p 80:80 temp-nginx
}

function tag_and_push_to_registry() {
  echo "bootstrap => Pushing reverse-proxy to dockerhub"
  docker tag temp-nginx mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap
  docker push mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap
}

function dispose_temp_nginx() {
  echo "bootstrap => Disposing temp nginx and its image"
  docker rm -fv temp-nginx | xargs echo "bootstrap => Removed container"
  docker rmi temp-nginx | xargs echo "bootstrap => Removed image"
}


build_and_run_temp_nginx

source ../helper.sh 
wait_until_service_is_at_running_state "registry_registry"

tag_and_push_to_registry
dispose_temp_nginx
