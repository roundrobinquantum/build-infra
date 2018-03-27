#!/bin/bash

set -e

GITLAB_ROOT_PASSWORD=""

function bootstrap() {

  echo "bootstrap => Process is started."

  create_build_network

  create_registry_image

  create_registry
  create_reverse_proxy
  create_gitlab
  create_gocd_server
  # create_nexus

  echo "bootstrap => Process is completed."
}

function create_build_network() {
  # Create an overlay and attachable network for communication between services
  echo "bootstrap => Creating a build network"
  docker network create -d overlay --attachable build | xargs echo "bootstrap => build network created with id :"
}

function create_registry_image() {
  echo "bootstrap => Creating registry image with pulling from officially dockerhub"
  registry/image/create.sh
}

function create_registry() {
  echo "bootstrap => Creating registry"
  docker stack deploy --compose-file registry/docker-compose.bootstrap.yml registry | xargs echo "bootstrap =>"
}  

function create_reverse_proxy() {
  # Creating a temp reverse proxy for generating real one
  echo "bootstrap => Creating a temp proxy"
  cd bootstrapper/temp-proxy && ./create_temp_proxy.sh && cd -
  
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
  
  wait_until_gitlab_is_healthy

  generate_gitlab_root_password

  # create_gitlab_group_and_project

  # push_build_infra_to_gitlab
}

function create_gocd_server() {
  # Push gocd server to registry
  echo "bootstrap => Creating gocd server image"
  gocd-server/image/create.sh

  # GoCD server
  echo "bootstrap => Creating gocd server"
  docker stack deploy --compose-file gocd-server/docker-compose.bootstrap.yml gocd
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
   if [ ${TIMEOUT_THRESHOLD} -eq 15 ]; then
       echo "dispose => Timeout threshold reached its own limit for gitlab. Some errors may have occured. Please check gitlab service. Exiting.."
       return 1
    fi

    STATE_OF_GITLAB=$(docker ps | grep gitlab | awk {'print $1'} | xargs --no-run-if-empty docker inspect -f {{.State.Health.Status}})

    if [ "${STATE_OF_GITLAB}" != "healthy" ]; then
      echo "bootstrap => Waiting to gitlab's health is healthy Try Count : ${TIMEOUT_THRESHOLD}"
      SLEEP_IN_SECOND=$((40 - (${TIMEOUT_THRESHOLD} * 4)))
      if [ "${SLEEP_IN_SECOND}" -lt 10 ]; then
       SLEEP_IN_SECOND=10
      fi

      sleep ${SLEEP_IN_SECOND}
      TIMEOUT_THRESHOLD=$[TIMEOUT_THRESHOLD +1]
    else
      GITLAB_IS_HEALTHY=true
      echo "bootstrap => Gitlab is healthy"
    fi
  done
}

function generate_gitlab_root_password() {
  echo "bootstrap => Building openssl for creating password"
  cd helpers/openssl/image && ./create.sh && cd -

  echo "bootstrap => Generating gitlab's root password with openssl"
  GITLAB_ROOT_PASSWORD=`docker run --rm openssl rand -base64 10`
  docker rmi openssl

  echo "bootstrap => Creating a standalone selenium hub"
  docker stack deploy --compose-file helpers/selenium-hub/docker-compose.yml selenium

  source bootstrapper/helper.sh 
  wait_until_service_is_at_running_state "selenium_chrome" "25"

  echo "bootstrap => Creating agouti for connecting to standalone chrome"
  cd bootstrapper/gitlab/root-password && ./create.sh && cd -

  echo "bootstrap => Entering root password to gitlab."
  docker run -d -e GITLAB_ROOT_PASSWORD=${GITLAB_ROOT_PASSWORD} -e GITLAB_URL='http://mpl-gitlab.hepsiburada.com' --network build gitlab-root-password
}

function create_gitlab_group_and_project() {
  echo "bootstrap => Creating a gitlab group named mpl and and build-infra project"

  cd bootstrapper/gitlab/config && ./create.sh && cd -
  docker run --rm -d gitlab-config

  echo "bootstrap => Removing image"
  docker rmi gitlab-config
}

function push_build_infra_to_gitlab() {
  alias git="docker run -ti --rm -v $(pwd):/git alpine/git"
  git add .
  git -c "user.name=root" -c "user.email=root@gitlab.com" commit -m"Initial Commit"
  git remote set-url origin http://root:${GITLAB_ROOT_PASSWORD}@mpl-gitlab.hepsiburada.com/mpl/build-infra.git
  git push
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