ARG IMAGE_NAME="debian"
ARG IMAGE_TAG="10-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

WORKDIR /root

RUN set -eux \
  && apt-get update && apt-get install -y --no-install-recommends \
     bash \
     ca-certificates \
     curl \
     git-core \
     openssh-client \
  && git clone https://github.com/tfutils/tfenv.git ~/.tfenv \
  && echo 'PATH=${HOME}/.tfenv/bin:/usr/local/bin:${PATH}' >> ~/.bashrc \
  && curl -fsSLo /usr/local/bin/kubectl \
     "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bin/bash"]
