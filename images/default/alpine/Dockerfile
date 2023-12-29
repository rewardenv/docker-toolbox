ARG IMAGE_NAME="alpine"
ARG IMAGE_TAG="3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY --from=quay.io/terraform-docs/terraform-docs:0.14.1 /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY rootfs/ /

WORKDIR /root

ENV PATH="${HOME}/.tfenv/bin:/usr/local/bin:${PATH}"
ENV HELM_VERSION=3.13.2
ENV HELM_RELEASE_FILE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"

RUN set -eux \
    && apk add --update --no-cache \
    bash \
    bzip2 \
    ca-certificates \
    coreutils \
    curl \
    findutils \
    git \
    git-crypt \
    gzip \
    jq \
    mysql-client \
    openssh-client \
    pigz \
    tar \
    unzip \
    xz \
    zip \
    && git clone --depth 1 https://github.com/tfutils/tfenv.git ~/.tfenv \
    && git clone --depth 1 https://github.com/tgenv/tgenv.git ~/.tgenv \
    && echo 'PATH=${HOME}/.tfenv/bin:${HOME}/.tgenv/bin:/usr/local/bin:${PATH}' >> ~/.bashrc \
    && curl -fsSLo /usr/local/bin/kubectl  \
        "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && cd /tmp \
    && curl -L https://get.helm.sh/${HELM_RELEASE_FILE} | tar xvz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && chmod +x /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/baseurl-update.sh \
    && chmod +x /usr/local/bin/import-db.sh \
    && chmod +x /usr/local/bin/import-media.sh \
    && chmod +x /usr/local/bin/export-db.sh \
    && chmod +x /usr/local/bin/export-media.sh \
    && rm -rf /var/cache/apk/* \
    && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd \
    && ln -sf /bin/bash /bin/sh

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
