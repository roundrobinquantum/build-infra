# Build Infrastructure

* [Introduction](#introduction)
* [Assumptions](#Assumptions)
* [Bootstrapping](#Bootstrapping)
* [Warnings](#Warnings)

## Introduction
 This project contains all the *IaC* (Infrastructure as Code) files for the build infrastructure. Folders are grouped according to the relevant build components, such as gitlab, gocd, nexus, etc.

## Assumptions
 - Docker is installed on the infrastructure host
 - 'mpl' user is created with sudo access, bash as the default shell, and is added to the 'docker' group
 - Build infrastructure will be based Docker Swarm, so all the Swarm ports should be accessible for the swarm traffic.
    - TCP port 2377 for cluster management communications
    - TCP and UDP port 7946 for communication among nodes
    - UDP port 4789 for overlay network traffic

## Bootstrapping
Bootstrapping is only necessary when the build infrastructure is provisioned **for the first time**. Bootstrapping will install barebone build infra services; Gitlab, GoCD, Docker Registry, Reverse Proxy (Nginx) and Nexus (not-mandatory). 

> **Warning**
Running a bootstrap process on a previously bootstrapped machine may lead to irrecovable consequences

In order to bootstrap the build infrastructure, you need to login (via SSH) to the target machine with 'mpl' user.

 - First, you need to get the IaC for the build infrastructure
```shell
docker run --rm -v $(pwd):/git alpine/git clone https://[PATH TO GIT REPO]/build-infra.git 
```
- Then, just invoke the bootstrap.sh
```shell
cd /build-infra/ && ./bootstrap.sh
```

