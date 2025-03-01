# hadolint global ignore=DL3006,DL3013,DL3018

ARG BUILD_IMAGE=alpine:3.21
ARG RUNTIME_IMAGE=ghcr.io/spirkaa/ansible:base

FROM ${BUILD_IMAGE} AS build

ARG CURL="curl -fsSL"

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]
WORKDIR /tmp

RUN apk add --update --no-cache \
        curl

RUN YQ_VERSION="$(${CURL} -o /dev/null -w %\{url_effective\} https://github.com/mikefarah/yq/releases/latest | sed 's/^.*\///g' )" \
    && ${CURL} "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz" | tar xzO ./yq_linux_amd64 > yq \
    && chmod +x yq \
    && ./yq --version | grep -E "${YQ_VERSION}"

RUN HELM_VERSION="$(${CURL} -o /dev/null -w %\{url_effective\} https://github.com/helm/helm/releases/latest | sed 's/^.*\///g' )" \
    && ${CURL} "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar xzO linux-amd64/helm > helm \
    && chmod +x helm \
    && ./helm version | grep -E "${HELM_VERSION}"

RUN KUBECTL_VERSION="$(${CURL} https://storage.googleapis.com/kubernetes-release/release/stable.txt)" \
    && ${CURL} -o kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && ./kubectl version --client 2>&1 | grep -E "${KUBECTL_VERSION}"


FROM ${RUNTIME_IMAGE} AS runtime

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

COPY --from=build /tmp/yq /usr/local/bin/yq
COPY --from=build /tmp/helm /usr/local/bin/helm
COPY --from=build /tmp/kubectl /usr/local/bin/kubectl

RUN pip install --no-cache-dir kubernetes \
    && ansible-galaxy collection install --no-cache kubernetes.core -p /usr/share/ansible/collections
