ARG IMAGE_NAME="debian"
ARG IMAGE_TAG="bookworm-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY rootfs/ /
COPY --from=mikefarah/yq /usr/bin/yq /usr/bin/yq

WORKDIR /root

ENV PATH="/usr/local/bin:${PATH}"
ENV HELM_VERSION=3.17.4
ENV TENV_AUTO_INSTALL=true
ENV TENV_VERSION=4.7.6

RUN <<-EOF
    set -eux
    apt-get update && apt-get install -y --no-install-recommends \
        bash \
        bzip2 \
        ca-certificates \
        curl \
        default-mysql-client-core \
        direnv \
        git-core \
        git-crypt \
        gnupg \
        gzip \
        jq \
        openssh-client \
        openssl \
        pigz \
        tar \
        unzip \
        wget \
        xz-utils \
        zip
    echo 'PATH=/usr/local/bin:${PATH}' >> ~/.bashrc
    echo 'alias tg=terragrunt' >> ~/.bashrc
    echo 'alias tf=tofu' >> ~/.bashrc
    echo 'alias k=kubectl' >> ~/.bashrc
    echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
    BUILD_ARCH="$(dpkg --print-architecture)"
    curl -fsSLo /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${BUILD_ARCH}/kubectl"
    cd /tmp
    curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${BUILD_ARCH}.tar.gz" | tar xvz
    mv linux-${BUILD_ARCH}/helm /usr/local/bin/helm
    curl -fsSLo /tmp/tenv.deb "https://github.com/tofuutils/tenv/releases/latest/download/tenv_v${TENV_VERSION}_${BUILD_ARCH}.deb"
    dpkg -i tenv.deb
    chmod +x /usr/local/bin/helm
    chmod +x /usr/local/bin/kubectl
    chmod +x /usr/local/bin/baseurl-update.sh
    chmod +x /usr/local/bin/import-db.sh
    chmod +x /usr/local/bin/import-media.sh
    chmod +x /usr/local/bin/export-db.sh
    chmod +x /usr/local/bin/export-media.sh
    rm -rf /var/lib/apt/lists/* /tmp/*
    ln -sf /bin/bash /bin/sh
EOF

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
