#!/bin/bash

set -e

function wait_until_registry_is_running() {
    
    REGISTRY_IS_RUNNING=false

    until [ "${REGISTRY_IS_RUNNING}" == "true" ]
    do

      STATE_OF_REGISTRY=$(docker service ps --format {{.ID}} registry_registry | xargs docker inspect -f {{.Status.State}})

      if [ "$STATE_OF_REGISTRY" != "running" ]; then
        echo "bootstrap => Waiting for registry is at running state"
        sleep 10
      else
        REGISTRY_IS_RUNNING=true
        echo "bootstrap => Registry is running"
      fi
    done
}

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
  echo "Disposing temp nginx and its image"
  docker rm -fv temp-nginx | xargs echo "bootstrap => Removed container"
  docker rmi temp-nginx | xargs echo "bootstrap => Removed image"
}


build_and_run_temp_nginx
wait_until_registry_is_running
tag_and_push_to_registry
dispose_temp_nginx
