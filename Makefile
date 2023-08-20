.POSIX:

export DOCKER_BUILDKIT=1

GITEA_TAG=git.devmem.ru/projects/ansible
GHCR_TAG=ghcr.io/spirkaa/ansible

default: build

build:
	@docker build \
		--cache-from ${GITEA_TAG}:base \
		--tag ${GITEA_TAG}:base \
		--tag ${GHCR_TAG}:base \
		-f .docker/base.Dockerfile .
	@docker build \
		--cache-from ${GITEA_TAG}:k8s \
		--tag ${GITEA_TAG}:k8s \
		--tag ${GHCR_TAG}:k8s \
		-f .docker/k8s.Dockerfile .
	@docker build \
		--cache-from ${GITEA_TAG}:infra \
		--tag ${GITEA_TAG}:infra \
		--tag ${GHCR_TAG}:infra \
		-f .docker/infra.Dockerfile .

build-nocache:
	@docker build \
		--pull --no-cache \
		--tag ${GITEA_TAG}:base \
		--tag ${GHCR_TAG}:base \
		-f .docker/base.Dockerfile .
	@docker build \
		--pull \
		--no-cache \
		--tag ${GITEA_TAG}:k8s \
		--tag ${GHCR_TAG}:k8s \
		-f .docker/k8s.Dockerfile .
	@docker build \
		--pull --no-cache \
		--tag ${GITEA_TAG}:infra \
		--tag ${GHCR_TAG}:infra \
		-f .docker/infra.Dockerfile .
