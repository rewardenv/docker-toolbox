ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="debian-bookworm-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN <<-EOF
    set -eux
    apt-get update && apt-get install -y --no-install-recommends \
        openvpn \
        python3 \
        python3-pip \
        python3-setuptools
    PIP_ARGS=""
    eval 'version_gt() { test "$(printf "%s\n" "$@" | sort -V | head -n 1)" != "$1"; }'
    if version_gt "$(cat /etc/os-release | grep 'VERSION_ID=' | cut -d'=' -f2 | tr -d '"')" "11"; then PIP_ARGS="--break-system-packages"; fi
    pip3 install --upgrade pip ${PIP_ARGS}
    pip3 install --no-cache-dir ${PIP_ARGS} \
        'ansible<2.11' \
        'hcloud'
    rm -rf /var/lib/apt/lists/*
EOF
