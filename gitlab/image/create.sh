#!/bin/bash

set -e

docker pull gitlab/gitlab-ce:10.2.8-ce.0
docker tag gitlab/gitlab-ce:10.2.8-ce.0 mpl-dockerhub.hepsiburada.com/gitlab:v10.2.8
docker push mpl-dockerhub.hepsiburada.com/gitlab:v10.2.8