ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN set -eux \
    && apk add --update --no-cache \
    python3 \
    py3-pip \
    && PIP_ARGS="" \
    && eval 'version_gt() { test "$(printf "%s\n" "$@" | sort -V | head -n 1)" != "$1"; }' \
    && if version_gt "$(cat /etc/os-release | grep 'VERSION_ID=' | cut -d'=' -f2 | tr -d '"')" "3.18.99"; then PIP_ARGS="--break-system-packages"; fi \
    && pip3 install --upgrade pip $PIP_ARGS \
    && pip3 install --no-cache-dir --break-system-packages \
    awscli \
    && rm -rf /var/cache/apk/*
