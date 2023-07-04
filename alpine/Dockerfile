ARG IMAGE_NAME="alpine"
ARG IMAGE_TAG="3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY --from=quay.io/terraform-docs/terraform-docs:0.14.1 /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs
COPY rootfs/ /

WORKDIR /root

ENV PATH="${HOME}/.tfenv/bin:/usr/local/bin:${PATH}"

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
    && git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
    && echo 'PATH=${HOME}/.tfenv/bin:/usr/local/bin:${PATH}' >> ~/.bashrc \
    && curl -fsSLo /usr/local/bin/kubectl  \
        "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
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
