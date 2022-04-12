.POSIX:

export DOCKER_BUILDKIT=1

TAG=git.devmem.ru/cr/ansible

default: build

build:
	@docker build --tag ${TAG}:base -f .docker/base.Dockerfile .
	@docker build --tag ${TAG}:k8s -f .docker/k8s.Dockerfile .
	@docker build --tag ${TAG}:infra -f .docker/infra.Dockerfile .
