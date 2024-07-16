ARG IMAGE_NAME="alpine"
ARG IMAGE_TAG="3.20"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY rootfs/ /

WORKDIR /root

ENV PATH="/usr/local/bin:${PATH}"
ENV HELM_VERSION=3.13.2
ENV TENV_AUTO_INSTALL=true

RUN <<-EOF
    set -eux
    apk add --update --no-cache \
        bash \
        bzip2 \
        ca-certificates \
        coreutils \
        curl \
        direnv \
        findutils \
        git \
        git-crypt \
        gnupg \
        gzip \
        jq \
        mysql-client \
        openssh-client \
        openssl \
        pigz \
        tar \
        unzip \
        wget \
        xz \
        zip
    echo 'PATH=/usr/local/bin:${PATH}' >> ~/.bashrc
    echo 'alias tg=terragrunt' >> ~/.bashrc
    echo 'alias tf=tofu' >> ~/.bashrc
    echo 'alias k=kubectl' >> ~/.bashrc
    apk add tenv --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
    BUILD_ARCH="$(apk --print-arch)"
    if [ "${BUILD_ARCH}" = "aarch64" ]; then BUILD_ARCH="arm64"; else BUILD_ARCH="amd64"; fi
    curl -fsSLo /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    cd /tmp
    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${BUILD_ARCH}.tar.gz | tar xvz
    mv linux-${BUILD_ARCH}/helm /usr/local/bin/helm
    chmod +x /usr/local/bin/helm
    chmod +x /usr/local/bin/kubectl
    chmod +x /usr/local/bin/baseurl-update.sh
    chmod +x /usr/local/bin/import-db.sh
    chmod +x /usr/local/bin/import-media.sh
    chmod +x /usr/local/bin/export-db.sh
    chmod +x /usr/local/bin/export-media.sh
    rm -rf /var/cache/apk/* /tmp/*
    sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
    ln -sf /bin/bash /bin/sh
EOF

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
