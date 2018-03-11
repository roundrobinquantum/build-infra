#!/bin/bash

set -e
docker build -t mpl-dockerhub.hepsiburada.com/gocd-agent-docker-client:v18.1.0 .
docker push mpl-dockerhub.hepsiburada.com/gocd-agent-docker-client:v18.1.0