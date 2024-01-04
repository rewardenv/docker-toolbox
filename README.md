# Docker Toolbox

## docker-toolbox

A docker toolbox image based on alpine/debian/ubuntu with these tools included:
- compression tools (bzip2, gzip, pigz, zip, xz)
- coreutils (for advanced base64 in alpine)
- curl
- findutils (for advanced xargs in alpine)
- git
- helm
- kubectl
- mysql-client
- openssl
- openssh-client
- tfenv
- tgenv
- wget

## docker-toolbox-testing

A docker toolbox image based on alpine/debian/ubuntu with these tools included:
- compression tools (bzip2, gzip, pigz, zip, xz)
- coreutils (for advanced base64 in alpine)
- curl
- findutils (for advanced xargs in alpine)
- git
- openssl
- trivy
- wget

# docker-toolbox-aws

A docker toolbox image based on rewardenv/docker-toolbox with these additional tools included:
- awscli
- python3
- pip3

## docker-toolbox-extended

A docker toolbox image based on rewardenv/docker-toolbox with these additional tools included:
- awscli
- google-cloud-sdk
- python3
- pip3
- terraform-docs

## docker-toolbox-ansible

A docker toolbox image based on rewardenv/docker-toolbox with these additional tools included:
- python3
- pip3
- openvpn
- ansible
- hcloud pip package

## Usage

```console
$ docker run --rm -it rewardenv/docker-toolbox bash
```

## Available tags

- latest, alpine-latest
- debian-bullseye-slim

## Build base image

```
$ DOCKER_BASE_IMAGE=debian:bullseye-slim bash -x scripts/build.sh
$ DOCKER_BASE_IMAGE=alpine:latest bash -x scripts/build.sh
```

## Build additional images

```console
$ DOCKER_BASE_IMAGE=alpine:latest FLAVOR=testing IMAGE_NAME=docker-toolbox-testing bash -x scripts/build.sh
$ DOCKER_BASE_IMAGE=alpine:latest FLAVOR=extended FROM_IMAGE=rewardenv/docker-toolbox IMAGE_NAME=docker-toolbox-extended bash -x scripts/build.sh
```