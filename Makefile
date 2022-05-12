.POSIX:

export DOCKER_BUILDKIT=1

IMAGE_FULLNAME=git.devmem.ru/projects/ansible

default: build

build:
	@docker build \
		--cache-from ${IMAGE_FULLNAME}:base \
		--tag ${IMAGE_FULLNAME}:base \
		-f .docker/base.Dockerfile .
	@docker build \
		--cache-from ${IMAGE_FULLNAME}:k8s \
		--tag ${IMAGE_FULLNAME}:k8s \
		-f .docker/k8s.Dockerfile .
	@docker build \
		--cache-from ${IMAGE_FULLNAME}:infra \
		--tag ${IMAGE_FULLNAME}:infra \
		-f .docker/infra.Dockerfile .

build-nocache:
	@docker build \
		--pull --no-cache \
		--tag ${IMAGE_FULLNAME}:base \
		-f .docker/base.Dockerfile .
	@docker build \
		--pull \
		--no-cache \
		--tag ${IMAGE_FULLNAME}:k8s \
		-f .docker/k8s.Dockerfile .
	@docker build \
		--pull --no-cache \
		--tag ${IMAGE_FULLNAME}:infra \
		-f .docker/infra.Dockerfile .
