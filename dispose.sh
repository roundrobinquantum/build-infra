#!/bin/bash

set -e

function dispose() {

  echo "dispose => Disposing the build environment is started."

  # Remove all stacks in attached build network
  remove_stacks

  # Find all images in build network before removing stacks.
  find_images_in_build_network

  # Wait until all stacks removed
  wait_until_stacks_are_removed

  # prune the containers with force
  docker_container_prune
  
  # clean up volumes
  docker_volume_prune

  # remove non using images in build network
  remove_non_using_images

  # prune the entire system
  docker_system_prune

  echo "dispose => Disposing complete. Deleted all volumes, all images and all services attached to build network."
}

function find_images_in_build_network() {
  export IMAGES_IN_BUILD_NETWORK=$(docker ps --filter network=build --format '{{.Image}}')
}

function remove_stacks() {

  STACKS_IN_BUILD_NETWORK=$(docker ps --filter network=build --format '{{.Label "com.docker.stack.namespace"}}')

  if [[ ${STACKS_IN_BUILD_NETWORK} ]]; then
     echo "dispose => Removing all stacks in attached build network"
     docker stack rm ${STACKS_IN_BUILD_NETWORK} | xargs echo "dispose =>"
  else
     echo "dispose => Nothing found in stack. Exiting.."
     return 1
  fi
}

function wait_until_stacks_are_removed() {

  STACKS_ARE_REMOVED=false
  TIMEOUT_THRESHOLD=0

  until [ "${STACKS_ARE_REMOVED}" == "true" ]
  do
    if [ ${TIMEOUT_THRESHOLD} -eq 4 ]; then
       echo "dispose => Timeout threshold reached its own limit. Exiting.."
       return 1
    fi 

    INITIAL_STATE_OF_STACKS=$(docker ps --filter network=build --format '{{.Label "com.docker.stack.namespace"}}')

    if [[ ${INITIAL_STATE_OF_STACKS} ]]; then
      echo "dispose => Waiting for gracefully shutting down stacks"
      sleep 5
      let TIMEOUT_THRESHOLD=TIMEOUT_THRESHOLD+1
    else
      STACKS_ARE_REMOVED=true
      echo "dispose => All stacks in build network gracefully removed"
    fi
  done
}

function docker_container_prune() {
  echo "dispose => Pruning the containers"
  docker container prune --force
}

function docker_volume_prune() {
  echo "dispose => Pruning the volumes"
  docker volume prune --force
}

function docker_system_prune() {
  echo "dispose => Pruning the system"
  docker system prune --force
}

function remove_non_using_images() {

  if [[ ${IMAGES_IN_BUILD_NETWORK} ]]; then
    echo "dispose => Removing non using images"
    docker rmi -f ${IMAGES_IN_BUILD_NETWORK}
  else
    echo -e "dispose => Non using images not found... Moving on..."
  fi
}

read -p "You're about to dispose the entire core build infrastructure!!!. This task will remove all docker stacks and your all images attached in build network. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) dispose;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac