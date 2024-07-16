ARG IMAGE_NAME="ubuntu"
ARG IMAGE_TAG="jammy"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

WORKDIR /root

ENV PATH="/usr/local/bin:${PATH}"

RUN <<-EOF
    set -eux
    apt-get update && apt-get install -y --no-install-recommends \
        apt-transport-https \
        bash \
        bzip2 \
        ca-certificates \
        curl \
        git-core \
        git-crypt \
        gnupg \
        gzip \
        jq \
        lsb-release \
        openssl \
        pigz \
        tar \
        unzip \
        wget \
        xz-utils \
        zip
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list
    apt-get update && apt-get install -y --no-install-recommends \
        trivy
    rm -rf /var/lib/apt/lists/*
    ln -sf /bin/bash /bin/sh
EOF

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
