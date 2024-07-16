ARG IMAGE_NAME="alpine"
ARG IMAGE_TAG="3.20"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

WORKDIR /root

ENV PATH="/usr/local/bin:${PATH}"

RUN <<-EOF
    set -eux
    apk add --update --no-cache \
        bash \
        bzip2 \
        ca-certificates \
        coreutils \
        curl \
        findutils \
        git \
        git-crypt \
        gnupg \
        gzip \
        jq \
        openssl \
        pigz \
        tar \
        unzip \
        xz \
        zip
    apk add trivy --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
    rm -rf /var/cache/apk/*
    sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
    ln -sf /bin/bash /bin/sh
EOF

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
