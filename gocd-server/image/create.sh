#!/bin/bash

set -e

docker pull gocd/gocd-server:v18.2.0
docker tag gocd/gocd-server:v18.2.0 mpl-dockerhub.hepsiburada.com/gocd-server:v18.2.0
docker push mpl-dockerhub.hepsiburada.com/gocd-server:v18.2.0