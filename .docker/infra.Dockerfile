# hadolint global ignore=DL3006,DL3018

ARG BUILD_IMAGE=alpine:3.17
ARG RUNNER_IMAGE=ghcr.io/spirkaa/ansible:k8s

FROM ${BUILD_IMAGE} AS builder

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

WORKDIR /tmp

RUN apk add --update --no-cache \
        curl \
        unzip

RUN TERRAFORM_VERSION="$(curl -fsSL -o /dev/null -w %\{url_effective\} https://github.com/hashicorp/terraform/releases/latest | sed 's/^.*\/v//g' )" \
    && curl -fsSL -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip \
    && chmod +x terraform \
    && ./terraform version | grep -E "${TERRAFORM_VERSION}"

RUN PACKER_VERSION="$(curl -fsSL -o /dev/null -w %\{url_effective\} https://github.com/hashicorp/packer/releases/latest | sed 's/^.*\/v//g' )" \
    && curl -fsSL -O "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
    && unzip packer_"${PACKER_VERSION}"_linux_amd64.zip \
    && chmod +x packer \
    && ./packer version | grep -E "${PACKER_VERSION}"


FROM ${RUNNER_IMAGE} AS runner

COPY --from=builder tmp/terraform /usr/bin/terraform
COPY --from=builder tmp/packer /usr/bin/packer

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

CMD [ "/bin/bash" ]
