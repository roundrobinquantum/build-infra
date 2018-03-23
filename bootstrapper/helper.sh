#!/bin/bash

set -e

function wait_until_service_is_at_running_state() {

    if [ -z "$1" ]; then
      echo "No argument supplied"
    fi

    TIMEOUT_THRESHOLD=0
    TRY_COUNT=0

    if [ -z "$2" ]; then
      echo "bootstrap => Argument for timeout threshold is empty. Setting to default 5"
      TIMEOUT_THRESHOLD=5
    else
      TIMEOUT_THRESHOLD=$2
    fi

    SERVICE_IS_RUNNING=false
    SERVICE_NAME=$1

    until [ "${SERVICE_IS_RUNNING}" == "true" ]
    do

      if [ ${TRY_COUNT} -eq 1 ]; then
        echo "dispose => Timeout threshold reached its own limit for service name : ${SERVICE_NAME}. Some errors may have occured. Please check service. Exiting.."
        return 1
      fi

      STATE_OF_SERVICE=$(docker service ps --format {{.ID}} ${SERVICE_NAME} | xargs docker inspect -f {{.Status.State}})

      if [ "${STATE_OF_SERVICE}" != "running" ]; then
        echo "bootstrap => Waiting for registry is at running state."
        sleep 5
        TRY_COUNT=$[TRY_COUNT +1]
      else
        SERVICE_IS_RUNNING=true
        echo "bootstrap => ${SERVICE_NAME} is running"
      fi
    done
}