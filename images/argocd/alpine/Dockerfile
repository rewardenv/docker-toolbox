ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.20"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

RUN <<-EOF
    set -eux
    BUILD_ARCH="$(apk --print-arch)"
    if [ "${BUILD_ARCH}" = "aarch64" ]; then BUILD_ARCH="arm64"; else BUILD_ARCH="amd64"; fi
    curl -sLO "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${BUILD_ARCH}" && \
    chmod +x "argocd-linux-${BUILD_ARCH}"
    mv "argocd-linux-${BUILD_ARCH}" /usr/local/bin/argocd
EOF
