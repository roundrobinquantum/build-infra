#!/bin/bash

set -e

function dispose() {

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
  # Remove all stacks
  docker stack rm $(docker stack ls | awk {'print $1'})
}

function docker_prune() {
  docker system prune --force
}

read -p "You're about to dispose the entire core build infrastructure!!!.This task will remove all docker stacks and your all images. Do you want to continue? (yes/no)" choice
case "$choice" in 
  yes|Yes ) cleanup;;
  no|No ) ;;
  * ) echo "Entered invalid choice";;
esac