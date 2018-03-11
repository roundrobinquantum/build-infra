#!/bin/bash

set -e

function bootstrap() {

  echo "Bootstrap process is started"

  create_build_network

  create_registry
  create_reverse_proxy
  create_gitlab
  create_gocd_server
  create_nexus

  echo "Bootstrap process is completed."
}

function create_build_network(){
  # Create overlay and attachable network for communication between services
  docker network create -d overlay --attachable build
}

function create_registry() {
  docker stack deploy --compose-file registry/docker-compose.bootstrap.yml registry
}  

function create_reverse_proxy() {
  # Creating temp reverse proxy for generating real one
  cd bootstrapper && ./create_temp_proxy.sh && cd -
  
  # Real reverse proxy
  docker stack deploy --compose-file reverse-proxy/docker-compose.bootstrap.yml reverse-proxy
}

function create_gitlab() {
  # Push gitlab to registry
  gitlab/image/create.sh

  # Gitlab
  docker stack deploy --compose-file gitlab/docker-compose.bootstrap.yml gitlab
}

function create_gocd_server() {
  # Push gocd server to registry
  gocd-server/image/create.sh

   # GoCD server
  docker stack deploy --compose-file gocd-server/docker-compose.bootstrap.yml gocd-server
}

function create_nexus() {
  # Push nexus to registry
  cd nexus/image && ./create.sh && cd -

   # Nexus
  docker stack deploy --compose-file nexus/docker-compose.bootstrap.yml nexus
}

read -p "You're about to begin the bootstrapper.This can lead to adverse consequences. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) bootstrap;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac