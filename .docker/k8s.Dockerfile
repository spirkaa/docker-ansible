# hadolint global ignore=DL3006,DL3013,DL3018

ARG BUILD_IMAGE=alpine:3.17
ARG RUNNER_IMAGE=ghcr.io/spirkaa/ansible:base

FROM ${BUILD_IMAGE} AS builder

SHELL [ "/bin/ash", "-euxo", "pipefail", "-c" ]

WORKDIR /tmp

RUN apk add --update --no-cache \
        curl \
        unzip

RUN HELM_VERSION="$(curl -fsSL -o /dev/null -w %\{url_effective\} https://github.com/helm/helm/releases/latest | sed 's/^.*\///g' )" \
    && curl -fsSL -O "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar xvfz "helm-${HELM_VERSION}-linux-amd64.tar.gz" --strip-components=1 \
    && chmod +x helm \
    && ./helm version | grep -E "${HELM_VERSION}"

RUN KUBECTL_VERSION="$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)" \
    && curl -fsSL -o kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && ./kubectl version --client --short=true 2>&1 | grep -E "${KUBECTL_VERSION}"


FROM ${RUNNER_IMAGE} AS runner

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

COPY --from=builder /tmp/helm /usr/bin/helm
COPY --from=builder /tmp/kubectl /usr/bin/kubectl

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir kubernetes \
    && ansible-galaxy collection install --no-cache kubernetes.core -p /usr/share/ansible/collections

CMD [ "/bin/bash" ]
