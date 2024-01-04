ARG IMAGE_NAME="ubuntu"
ARG IMAGE_TAG="jammy"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

WORKDIR /root

ENV PATH="/usr/local/bin:${PATH}"

RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bzip2 \
    ca-certificates \
    curl \
    git-core \
    git-crypt \
    gzip \
    jq \
    lsb-core \
    pigz \
    tar \
    unzip \
    xz-utils \
    zip \
    && echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | tee -a /etc/apt/sources.list.d/trivy.list \
    && apt-get update && apt-get install -y --no-install-recommends \
    trivy \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /bin/bash /bin/sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
