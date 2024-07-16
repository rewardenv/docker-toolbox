ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.20"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN <<-EOF
    set -eux
    apk add --update --no-cache \
        python3 \
        py3-pip
    PIP_ARGS=""
    eval 'version_gt() { test "$(printf "%s\n" "$@" | sort -V | head -n 1)" != "$1"; }'
    if version_gt "$(cat /etc/os-release | grep 'VERSION_ID=' | cut -d'=' -f2 | tr -d '"')" "3.18.99"; then PIP_ARGS="--break-system-packages"; fi
    pip3 install --no-cache-dir $PIP_ARGS \
        awscli
    curl -fsSLo /tmp/google-cloud-sdk.tar.gz \
        https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
    mkdir -p /usr/local/gcloud
    tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
    /usr/local/gcloud/google-cloud-sdk/install.sh --quiet
    rm -rf /var/cache/apk/* /tmp/*
EOF

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
