# hadolint global ignore=DL3006,DL3008

ARG BUILD_IMAGE=ghcr.io/spirkaa/python:3.11-bookworm-venv-builder
ARG RUNTIME_IMAGE=python:3.11-slim-bookworm

FROM ${BUILD_IMAGE} AS build

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

COPY requirements.txt /

RUN pip install --no-cache-dir -r requirements.txt


FROM ${RUNTIME_IMAGE} AS runtime

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/opt/venv/bin:$PATH"

SHELL [ "/bin/bash", "-euxo", "pipefail", "-c" ]

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        git \
        jq \
        libldap-2.5-0 \
        make \
        openssh-client \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/venv /opt/venv

COPY requirements.yml /

RUN ansible-galaxy role install -r requirements.yml -p /usr/share/ansible/roles \
    && ansible-galaxy collection install --no-cache -r requirements.yml -p /usr/share/ansible/collections \
    && rm -rf /root/.ansible \
    && chmod 777 /opt/venv/lib/python*/site-packages/ansible_mitogen  # this is needed for serverscom.mitogen to work

CMD [ "/bin/bash" ]
