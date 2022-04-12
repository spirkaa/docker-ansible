def buildImageCache(String tag) {
  IMAGE_TAG = "${tag}"
  DOCKERFILE = ".docker/${IMAGE_TAG}.Dockerfile"
  docker.withRegistry("${REGISTRY_URL}", "${REGISTRY_CREDS_ID}") {
    def myImage = docker.build(
      "${IMAGE_FULLNAME}:${IMAGE_TAG}",
      "--label \"org.opencontainers.image.created=${LABEL_CREATED}\" \
      --label \"org.opencontainers.image.authors=${LABEL_AUTHORS}\" \
      --label \"org.opencontainers.image.url=${LABEL_URL}\" \
      --label \"org.opencontainers.image.source=${GIT_URL}\" \
      --label \"org.opencontainers.image.version=${IMAGE_TAG}\" \
      --label \"org.opencontainers.image.revision=${REVISION}\" \
      --label \"org.opencontainers.image.title=${LABEL_TITLE}\" \
      --label \"org.opencontainers.image.description=${LABEL_DESCRIPTION}\" \
      --progress=plain \
      --cache-from ${IMAGE_FULLNAME}:${IMAGE_TAG} \
      -f ${DOCKERFILE} ."
    )
    myImage.push()
    sh "docker rmi -f \$(docker inspect -f '{{ .Id }}' ${myImage.id})"
  }
}

def buildImageNoCache(String tag) {
  IMAGE_TAG = "${tag}"
  DOCKERFILE = ".docker/${IMAGE_TAG}.Dockerfile"
  docker.withRegistry("${REGISTRY_URL}", "${REGISTRY_CREDS_ID}") {
    def myImage = docker.build(
      "${IMAGE_FULLNAME}:${IMAGE_TAG}",
      "--label \"org.opencontainers.image.created=${LABEL_CREATED}\" \
      --label \"org.opencontainers.image.authors=${LABEL_AUTHORS}\" \
      --label \"org.opencontainers.image.url=${LABEL_URL}\" \
      --label \"org.opencontainers.image.source=${GIT_URL}\" \
      --label \"org.opencontainers.image.version=${IMAGE_TAG}\" \
      --label \"org.opencontainers.image.revision=${REVISION}\" \
      --label \"org.opencontainers.image.title=${LABEL_TITLE}\" \
      --label \"org.opencontainers.image.description=${LABEL_DESCRIPTION}\" \
      --progress=plain \
      --pull \
      --no-cache \
      -f ${DOCKERFILE} ."
    )
    myImage.push()
    sh "docker rmi -f \$(docker inspect -f '{{ .Id }}' ${myImage.id})"
  }
}

pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
    disableConcurrentBuilds()
  }

    triggers {
      cron('0 7 * * 6')
    }

  environment {
    REGISTRY = 'git.devmem.ru'
    REGISTRY_URL = "https://${REGISTRY}"
    REGISTRY_CREDS_ID = 'gitea-user'
    IMAGE_OWNER = 'cr'
    IMAGE_BASENAME = 'ansible'
    IMAGE_FULLNAME = "${REGISTRY}/${IMAGE_OWNER}/${IMAGE_BASENAME}"
    LABEL_AUTHORS = 'Ilya Pavlov <piv@devmem.ru>'
    LABEL_TITLE = 'Ansible'
    LABEL_DESCRIPTION = 'Ansible for CI/CD pipelines'
    LABEL_URL = 'https://www.ansible.com'
    LABEL_CREATED = sh(script: "date '+%Y-%m-%dT%H:%M:%S%:z'", returnStdout: true).toString().trim()
    REVISION = GIT_COMMIT.take(7)
  }

  stages {
    stage('Set env vars') {
      steps {
        script {
          env.DOCKER_BUILDKIT = 1
        }
      }
    }

    stage('Build base image') {
      stages {
        stage('Build base image (cache)') {
          when {
            not {
              anyOf {
                triggeredBy 'TimerTrigger'
                triggeredBy cause: 'UserIdCause'
              }
            }
          }
          steps {
            script {
              buildImageCache 'base'
            }
          }
        }

        stage('Build base image (no cache)') {
          when {
            anyOf {
              triggeredBy 'TimerTrigger'
              triggeredBy cause: 'UserIdCause'
            }
          }
          steps {
            script {
              buildImageNoCache 'base'
            }
          }
        }
      }
    }

    stage('Build k8s image') {
      stages {
        stage('Build k8s image (cache)') {
          when {
            not {
              anyOf {
                triggeredBy 'TimerTrigger'
                triggeredBy cause: 'UserIdCause'
              }
            }
          }
          steps {
            script {
              buildImageCache 'k8s'
            }
          }
        }

        stage('Build k8s image (no cache)') {
          when {
            anyOf {
              triggeredBy 'TimerTrigger'
              triggeredBy cause: 'UserIdCause'
            }
          }
          steps {
            script {
              buildImageNoCache 'k8s'
            }
          }
        }
      }
    }

    stage('Build infra image') {
      stages {
        stage('Build infra image (cache)') {
          when {
            not {
              anyOf {
                triggeredBy 'TimerTrigger'
                triggeredBy cause: 'UserIdCause'
              }
            }
          }
          steps {
            script {
              buildImageCache 'infra'
            }
          }
        }

        stage('Build infra image (no cache)') {
          when {
            anyOf {
              triggeredBy 'TimerTrigger'
              triggeredBy cause: 'UserIdCause'
            }
          }
          steps {
            script {
              buildImageNoCache 'infra'
            }
          }
        }
      }
    }
  }
}
