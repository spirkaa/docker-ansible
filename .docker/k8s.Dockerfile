FROM alpine:3.15 AS build

RUN set -eux \
    && apk add --update --no-cache \
        curl \
        unzip

RUN set -eux \
    && cd /tmp \
    && HELM_VERSION="$(curl -fsS -L -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest | sed 's/^.*\///g' )" \
    && curl -fsS -L -O https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && tar xvfz helm-${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/bin/helm \
    && chmod +x /usr/bin/helm \
    && helm version | grep -E "${HELM_VERSION}"

RUN set -eux \
    && KUBECTL_VERSION="$(curl -fsS -L https://storage.googleapis.com/kubernetes-release/release/stable.txt)" \
    && curl -fsS -L -o /usr/bin/kubectl \
        https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/bin/kubectl \
    && kubectl version --client --short=true 2>&1 | grep -E "${KUBECTL_VERSION}"


FROM git.devmem.ru/cr/ansible:base AS prod

COPY --from=build /usr/bin/helm /usr/bin/helm
COPY --from=build /usr/bin/kubectl /usr/bin/kubectl

RUN set -eux \
    && pip install --no-cache-dir kubernetes

RUN set -eux \
    && ansible-galaxy collection install --no-cache kubernetes.core -p /usr/share/ansible/collections

CMD [ "/bin/bash" ]
