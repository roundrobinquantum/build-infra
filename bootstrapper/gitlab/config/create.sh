#!/bin/bash

set -e

docker build \
 --build-arg GITLAB_USER=root \
 --build-arg GITLAB_PASS=${GITLAB_ROOT_PASSWORD} \
 -t gitlab-config .