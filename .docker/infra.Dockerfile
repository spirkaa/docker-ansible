# hadolint global ignore=DL3006,DL3018

ARG BUILD_IMAGE=alpine:3.18
ARG RUNTIME_IMAGE=ghcr.io/spirkaa/ansible:k8s

FROM ${BUILD_IMAGE} AS build

ARG CURL="curl -fsSL"

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]
WORKDIR /tmp

RUN apk add --update --no-cache \
        curl

RUN TERRAFORM_VERSION="$(${CURL} -o /dev/null -w %\{url_effective\} https://github.com/hashicorp/terraform/releases/latest | sed 's/^.*\/v//g' )" \
    && ${CURL} -O "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && busybox unzip -n terraform_"${TERRAFORM_VERSION}"_linux_amd64.zip \
    && chmod +x terraform \
    && ./terraform version | grep -E "${TERRAFORM_VERSION}"

RUN PACKER_VERSION="$(${CURL} -o /dev/null -w %\{url_effective\} https://github.com/hashicorp/packer/releases/latest | sed 's/^.*\/v//g' )" \
    && ${CURL} -O "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
    && busybox unzip -n packer_"${PACKER_VERSION}"_linux_amd64.zip \
    && chmod +x packer \
    && ./packer version | grep -E "${PACKER_VERSION}"


FROM ${RUNTIME_IMAGE} AS runtime

COPY --from=build /tmp/terraform /usr/local/bin/terraform
COPY --from=build /tmp/packer /usr/local/bin/packer
