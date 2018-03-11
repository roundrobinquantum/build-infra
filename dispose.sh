#!/bin/bash

set -e

function dispose() {

  # Remove all stacks in attached build network
  remove_stacks

  # Wait for docker's gracefully stack removing 
  sleep 10

  # prune the system with force
  docker_prune
  
  # clean up volumes
  docker volume prune --force

  # last cleanup
  docker_prune

  sleep 15

  # remove images
  docker rmi -f $(docker image ls -aq)

  docker volume prune --force

  echo "cleanup complete. Deleted all volumes and all services"
}

function remove_stacks() {

  STACKS_IN_BUILD_NETWORK=$(docker ps --filter network=build --format '{{.Label "com.docker.stack.namespace"}}')

  if [[ $STACKS_IN_BUILD_NETWORK ]]; then
     echo "Removing all stacks in attached build network"
     docker stack rm $STACKS_IN_BUILD_NETWORK
  else
     echo "Nothing found in stack. Exiting"
     return 1
  fi
}

function docker_prune() {
  docker system prune --force
}

read -p "You're about to dispose the entire core build infrastructure!!!.This task will remove all docker stacks and your all images. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) dispose;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac