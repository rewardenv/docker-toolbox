ARG IMAGE_NAME="alpine"
ARG IMAGE_TAG="3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

WORKDIR /root

RUN set -eux \
  && apk add --update --no-cache \
     bash \
     ca-certificates \
     coreutils \
     curl \
     git \
     openssh-client \
  && git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
  && echo 'PATH=${HOME}/.tfenv/bin:/usr/local/bin:${PATH}' >> ~/.bashrc \
  && curl -fsSLo /usr/local/bin/kubectl \
     "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl \
  && rm -rf /var/cache/apk/*
