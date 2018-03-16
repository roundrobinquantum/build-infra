#!/bin/bash

set -e

function bootstrap() {

  echo "bootstrap => Process is started."

  create_build_network

  pull_registry_image

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

function pull_registry_image() {
  echo "bootstrap => Pulling registry image from dockerhub"
  docker pull registry:2.5
}

function create_registry() {
  echo "bootstrap => Creating registry"
  docker stack deploy --compose-file registry/docker-compose.bootstrap.yml registry | xargs echo "bootstrap =>"
}  

function create_reverse_proxy() {
  # Creating temp reverse proxy for generating real one
  echo "bootstrap => Creating a temp proxy"
  cd bootstrapper && ./create_temp_proxy.sh && cd -
  
  # Real reverse proxy
  echo "bootstrap => Creating reverse-proxy"
  docker stack deploy --compose-file reverse-proxy/docker-compose.bootstrap.yml reverse-proxy | xargs echo "bootstrap =>"
}

function create_gitlab() {
  # Push gitlab to registry
  echo "bootstrap => Creating gitlab image"
  gitlab/image/create.sh

  # Gitlab
  echo "bootstrap => Creating gitlab"
  docker stack deploy --compose-file gitlab/docker-compose.bootstrap.yml gitlab | xargs echo "bootstrap =>"
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

read -p "You're about to begin the bootstrapper.This can lead to adverse consequences. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) bootstrap;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac