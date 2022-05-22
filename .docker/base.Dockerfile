ARG PYTHON_IMAGE=python:3.10-slim-bullseye
ARG BUILD_IMAGE=git.devmem.ru/projects/python:3.10-bullseye-venv-builder

FROM ${BUILD_IMAGE} AS builder

COPY requirements.txt .

RUN set -eux \
    && pip install --no-cache-dir -r requirements.txt


FROM ${PYTHON_IMAGE} AS runner

RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        libldap-2.4-2 \
        make \
        openssh-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

COPY requirements.yml .

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

RUN set -eux \
    && ansible-galaxy role install -r requirements.yml -p /usr/share/ansible/roles \
    && ansible-galaxy collection install --no-cache -r requirements.yml -p /usr/share/ansible/collections \
    && rm -rf /root/.ansible

CMD [ "/bin/bash" ]
