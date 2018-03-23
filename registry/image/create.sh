#!/bin/bash

set -e

# If a container, deploys with stack or docker service, its image tag will be null
# According to this link : https://github.com/moby/moby/issues/28908. We are disposing bootstrapper images in dispose.sh. 
# So we need to identify image tag for correctly disposing images
# Best way to do this, manually create image and use it from docker-compose.yml
docker pull registry:2.5