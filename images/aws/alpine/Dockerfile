ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN set -eux \
    && apk add --update --no-cache \
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir \
    awscli \
    && rm -rf /var/cache/apk/*
