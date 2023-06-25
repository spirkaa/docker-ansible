# hadolint global ignore=DL3006,DL3008

ARG PYTHON_IMAGE=python:3.11-slim-bullseye
ARG BUILD_IMAGE=ghcr.io/spirkaa/python:3.11-bullseye-venv-builder

FROM ${BUILD_IMAGE} AS builder

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

COPY requirements.txt /

RUN pip install --no-cache-dir -r requirements.txt


FROM ${PYTHON_IMAGE} AS runner

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        libldap-2.4-2 \
        make \
        openssh-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv

COPY requirements.yml /

ENV PYTHONUNBUFFERED=1
ENV PATH="/opt/venv/bin:$PATH"

RUN ansible-galaxy role install -r requirements.yml -p /usr/share/ansible/roles \
    && ansible-galaxy collection install --no-cache -r requirements.yml -p /usr/share/ansible/collections \
    && rm -rf /root/.ansible \
    && chmod 777 /opt/venv/lib/python*/site-packages/ansible_mitogen  # this is needed for serverscom.mitogen to work

CMD [ "/bin/bash" ]
