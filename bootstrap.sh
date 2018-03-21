#!/bin/bash

set -e

function bootstrap() {

  echo "bootstrap => Process is started."

  create_build_network

  create_registry_image

  create_registry
  create_reverse_proxy
  create_gitlab
  create_gocd_server
  create_nexus

  echo "bootstrap => Process is completed."
}

function create_build_network() {
  # Create overlay and attachable network for communication between services
  echo "bootstrap => Creating build network"
  docker network create -d overlay --attachable build | xargs echo "bootstrap => build network created with id :"
}

function create_registry_image() {
  echo "bootstrap => Creating registry image from officially dockerhub"
  registry/image/create.sh
}

function create_registry() {
  echo "bootstrap => Creating registry"
  docker stack deploy --compose-file registry/docker-compose.bootstrap.yml registry | xargs echo "bootstrap =>"
}  

function create_reverse_proxy() {
  # Creating temp reverse proxy for generating real one
  echo "bootstrap => Creating a temp proxy"
  cd bootstrapper && ./create_temp_proxy.sh && cd -

  echo "bootstrap => Pulling an alpine image and pushing to registry"
  # pull_alpine_image_and_push_to_registry
  
  # Real reverse proxy
  echo "bootstrap => Creating reverse-proxy"
  docker stack deploy --compose-file reverse-proxy/docker-compose.bootstrap.yml reverse-proxy | xargs echo "bootstrap =>"
}

# function pull_alpine_image_and_push_to_registry() {

#   docker pull alpine:3.7
#   docker tag alpine:3.7 mpl-dockerhub.hepsiburada.com/alpine:3.7
#   docker push mpl-dockerhub.hepsiburada.com/alpine:3.7
# }

function create_gitlab() {
  # Push gitlab to registry
  echo "bootstrap => Creating gitlab image"
  gitlab/image/create.sh

  # Gitlab
  echo "bootstrap => Creating gitlab"
  docker stack deploy --compose-file gitlab/docker-compose.bootstrap.yml gitlab | xargs echo "bootstrap =>"
  
  wait_until_gitlab_is_healthy

  # generate_gitlab_root_password
}

function create_gocd_server() {
  # Push gocd server to registry
  echo "bootstrap => Creating gocd server image"
  gocd-server/image/create.sh

  # GoCD server
  echo "bootstrap => Creating gocd server"
  docker stack deploy --compose-file gocd-server/docker-compose.bootstrap.yml gocd-server
}

function create_nexus() {
  # Push nexus to registry
  echo "bootstrap => Creating nexus image"
  nexus/image/create.sh

  # Nexus
  echo "bootstrap => Creating nexus"
  docker stack deploy --compose-file nexus/docker-compose.bootstrap.yml nexus
}

function wait_until_gitlab_is_healthy() {

  GITLAB_IS_HEALTHY=false
  TIMEOUT_THRESHOLD=0

  until [ "${GITLAB_IS_HEALTHY}" == "true" ]
  do
   if [ ${TIMEOUT_THRESHOLD} -eq 10 ]; then
       echo "dispose => Timeout threshold reached its own limit for gitlab. Some errors may have occured. Please check gitlab service. Exiting.."
       return 1
    fi

    STATE_OF_GITLAB=$(docker ps | grep gitlab | awk {'print $1'} | xargs --no-run-if-empty docker inspect -f {{.State.Health.Status}})

    if [ "${STATE_OF_GITLAB}" != "healthy" ]; then
      echo "bootstrap => Waiting to gitlab's health is healthy"
      sleep 40
    else
      GITLAB_IS_HEALTHY=true
      echo "bootstrap => Gitlab is healthy"
    fi
  done
}

function generate_gitlab_root_password() {
  echo "bootstrap => Generating gitlab's root password"
  echo "bootstrap => Building openssl for creating password"

  cd helper-tools/openssl/image && ./create.sh && cd -

  docker run --rm openssl rand -base64 10 > passwd

  cat passwd | xargs echo "bootstrap => Generated gitlab password is :"

  export GITLAB_ROOT_PASS=$(cat passwd)

  rm -f passwd
}

function configure_gocd_server() {
  echo "bootstrapper => Configuring gocd server"
} 

read -p "You're about to begin the bootstrapper.This can lead to adverse consequences. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) bootstrap;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac