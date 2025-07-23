ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="debian-bookworm-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN <<-EOF
    set -eux
    BUILD_ARCH="$(dpkg --print-architecture)"
    curl -sLO "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${BUILD_ARCH}" && \
    chmod +x "argocd-linux-${BUILD_ARCH}"
    mv "argocd-linux-${BUILD_ARCH}" /usr/local/bin/argocd
EOF
