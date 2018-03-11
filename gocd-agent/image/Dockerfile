FROM gocd/gocd-agent-alpine-3.5:v18.1.0

# install curl to download the Docker version 17.09-ce binaries
RUN apk add --no-cache curl && \
  curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-17.12.0-ce.tgz && \
  tar --strip-components=1 -xvzf docker-17.12.0-ce.tgz -C /usr/local/bin && \
  rm -rf docker docker-17.12.0-ce.tgz && \
  # add goagent user "go" to docker group so that it can access docker.sock
  # "ping" group's GID collides with host's "docker" group's GID. simply remove group "ping"
  delgroup ping && \
  addgroup -g 999 docker && \
  addgroup go docker