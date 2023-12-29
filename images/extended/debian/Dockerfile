ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="debian-bullseye-slim"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY --from=quay.io/terraform-docs/terraform-docs:0.14.1 /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs

RUN set -eux \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    && PIP_ARGS="" \
    && eval 'version_gt() { test "$(printf "%s\n" "$@" | sort -V | head -n 1)" != "$1"; }' \
    && if version_gt "$(cat /etc/os-release | grep 'VERSION_ID=' | cut -d'=' -f2 | tr -d '"')" "11"; then PIP_ARGS="--break-system-packages"; fi \
    && pip3 install --no-cache-dir ${PIP_ARGS} \
    awscli \
    && curl -fsSLo /tmp/google-cloud-sdk.tar.gz \
      https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz \
    && mkdir -p /usr/local/gcloud \
    && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
    && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet \
    && rm -f /tmp/google-cloud-sdk.tar.gz \
    && rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
