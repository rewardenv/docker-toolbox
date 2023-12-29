ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="debian-bullseye-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends \
    openvpn \
    python3 \
    python3-pip \
    python3-setuptools \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    'ansible<2.11' \
    'hcloud' \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf