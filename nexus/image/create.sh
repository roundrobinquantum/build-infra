#!/bin/bash

set -e

docker pull sonatype/nexus3:3.8.0
docker tag sonatype/nexus3:3.8.0 mpl-dockerhub.hepsiburada.com/nexus:3.8.0
docker push mpl-dockerhub.hepsiburada.com/nexus:3.8.0