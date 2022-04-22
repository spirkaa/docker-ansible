ARG BUILD_IMAGE=alpine:3.15

FROM ${BUILD_IMAGE} AS builder

RUN set -eux \
    && apk add --update --no-cache \
        curl \
        unzip

RUN set -eux \
    && cd /tmp \
    && TERRAFORM_VERSION="$(curl -fsS -L -o /dev/null -w %{url_effective} https://github.com/hashicorp/terraform/releases/latest | sed 's/^.*\/v//g' )" \
    && curl -fsS -L -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin/ \
    && chmod +x /usr/bin/terraform \
    && terraform version | grep -E "${TERRAFORM_VERSION}"

RUN set -eux \
    && cd /tmp \
    && PACKER_VERSION="$(curl -fsS -L -o /dev/null -w %{url_effective} https://github.com/hashicorp/packer/releases/latest | sed 's/^.*\/v//g' )" \
    && curl -fsS -L -O https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip ./packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/bin/ \
    && chmod +x /usr/bin/packer \
    && packer version | grep -E "${PACKER_VERSION}"


FROM git.devmem.ru/cr/ansible:k8s AS runner

COPY --from=builder /usr/bin/terraform /usr/bin/terraform
COPY --from=builder /usr/bin/packer /usr/bin/packer

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

CMD [ "/bin/bash" ]
