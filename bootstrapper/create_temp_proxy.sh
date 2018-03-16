#!/bin/bash

set -e

function wait_until_registry_is_running() {
    
    REGISTRY_IS_RUNNING=false

    until [ "${REGISTRY_IS_RUNNING}" == "true" ]
    do

      STATE_OF_REGISTRY=$(docker service ps --format {{.ID}} registry_registry | xargs docker inspect -f {{.Status.State}})

      if [ "$STATE_OF_REGISTRY" != "running" ]; then
        echo -e "\nWaiting for registry is at running state\n"
        sleep 10
      else
        REGISTRY_IS_RUNNING=true
      fi
    done
}

function build_and_run_temp_nginx() {

  HOST_IP=$(ip route get 1 | awk '{print $NF;exit}')

  docker build -t temp-nginx --build-arg HOST_IP=${HOST_IP} .
  docker run --rm --name temp-nginx -d -p 80:80 temp-nginx
}

function tag_and_push_to_registry() {
  docker tag temp-nginx mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap
  docker push mpl-dockerhub.hepsiburada.com/reverse-proxy:bootstrap
}

function dispose_temp_nginx() {
  docker rm -fv temp-nginx
  docker rmi temp-nginx
}


build_and_run_temp_nginx
wait_until_registry_is_running
tag_and_push_to_registry
dispose_temp_nginx
