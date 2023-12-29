ARG IMAGE_NAME="rewardenv/docker-toolbox"
ARG IMAGE_TAG="alpine-3.14"
FROM ${IMAGE_NAME}:${IMAGE_TAG}

COPY --from=quay.io/terraform-docs/terraform-docs:0.14.1 /usr/local/bin/terraform-docs /usr/local/bin/terraform-docs

RUN set -eux \
    && apk add --update --no-cache \
    python3 \
    py3-pip \
    && pip3 install --no-cache-dir \
    awscli \
    && curl -fsSLo /tmp/google-cloud-sdk.tar.gz \
    https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz \
    && mkdir -p /usr/local/gcloud \
    && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
    && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet \
    && rm -f /tmp/google-cloud-sdk.tar.gz \
    && rm -rf /var/cache/apk/*

ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
