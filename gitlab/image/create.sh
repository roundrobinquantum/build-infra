#!/bin/bash

set -e

docker pull gitlab/gitlab-ce:10.5.6-ce.0
docker tag gitlab/gitlab-ce:10.5.6-ce.0 mpl-dockerhub.hepsiburada.com/gitlab:10.5.6
docker push mpl-dockerhub.hepsiburada.com/gitlab:10.5.6