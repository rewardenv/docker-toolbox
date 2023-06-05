# docker-toolbox

A docker toolbox image based on alpine/debian with these tools included:
- compression tools (bzip2, gzip, pigz, zip, xz)
- git
- curl
- tfenv
- kubectl
- mysql-client
- coreutils (for advanced base64 in alpine)
- findutils (for advanced xargs in alpine)


## Usage

```
docker run --rm -it rewardenv/docker-toolbox bash
```

## Available tags

- latest, alpine-latest
- debian-bullseye-slim

## Build

```
DOCKER_BASE_IMAGE=debian:bullseye-slim bash -x scripts/build.sh

DOCKER_BASE_IMAGE=alpine:latest bash -x scripts/build.sh  
```
