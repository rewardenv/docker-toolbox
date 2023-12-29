ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN set -eux \
    && apk add --update --no-cache \
    openvpn \
    python3 \
    py3-pip \
    py3-cryptography \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    'ansible<2.11' \
    'hcloud' \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf