#!/bin/bash

set -e

docker pull gitlab/gitlab-ce:10.5.4-ce.0
docker tag gitlab/gitlab-ce:10.5.4-ce.0 mpl-dockerhub.hepsiburada.com/gitlab:v10.5.4
docker push mpl-dockerhub.hepsiburada.com/gitlab:v10.5.4