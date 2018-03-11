#!/bin/bash

set -e

function dispose() {

  # Remove all stacks in attached build network
  remove_stacks

  # Wait until all stacks removed
  wait_until_stacks_are_removed

  # prune the system with force
  docker_system_prune
  
  # clean up volumes
  docker_volume_prune

  # remove non using images in build network
  remove_non_using_images

  echo "Disposing complete. Deleted all volumes, all images and all services attached to build network."
}

function remove_stacks() {

  export STACKS_IN_BUILD_NETWORK=$(docker ps --filter network=build --format '{{.Label "com.docker.stack.namespace"}}')

  if [[ $STACKS_IN_BUILD_NETWORK ]]; then
     echo "Removing all stacks in attached build network"
     docker stack rm $STACKS_IN_BUILD_NETWORK
  else
     echo "Nothing found in stack. Exiting"
     return 1
  fi
}

function wait_until_stacks_are_removed() {

  STACKS_ARE_REMAINING=false

  echo "waiting for gracefully shutting down stacks"

  until [ "${STACKS_ARE_REMAINING}" == "true" ] 
  do
    INITIAL_STATE_OF_STACKS=$(docker ps --filter network=build --format '{{.Label "com.docker.stack.namespace"}}')

    if [[ $INITIAL_STATE_OF_STACKS ]]; then
      STACKS_ARE_REMAINING=false
    else
      STACKS_ARE_REMAINING=true
    fi
  done
}

function docker_system_prune() {
  docker system prune --force
}

function docker_volume_prune() {
  docker volume prune --force
}

function remove_non_using_images(){

  IMAGES_IN_BUILD_NETWORK=$(docker ps --filter network=build --format '{{.Image}}')

  if [[ ${IMAGES_IN_BUILD_NETWORK} ]]; then
    echo "removing non using images"
    docker rmi -f ${IMAGES_IN_BUILD_NETWORK}
  else
    echo "Non using images not found... Moving on..."
  fi
}

read -p "You're about to dispose the entire core build infrastructure!!!.This task will remove all docker stacks and your all images. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) dispose;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac