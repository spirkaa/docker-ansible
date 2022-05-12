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
    IMAGE_OWNER = 'projects'
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
              buildDockerImage(
                dockerFile: '.docker/base.Dockerfile',
                tag: 'base',
                altTag: 'latest',
                useCache: true
              )
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
              buildDockerImage(
                dockerFile: '.docker/base.Dockerfile',
                tag: 'base',
                altTag: 'latest'
              )
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
              buildDockerImage(
                dockerFile: '.docker/k8s.Dockerfile',
                tag: 'k8s',
                useCache: true
              )
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
              buildDockerImage(
                dockerFile: '.docker/k8s.Dockerfile',
                tag: 'k8s'
              )
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
              buildDockerImage(
                dockerFile: '.docker/infra.Dockerfile',
                tag: 'infra',
                useCache: true
              )
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
              buildDockerImage(
                dockerFile: '.docker/infra.Dockerfile',
                tag: 'infra'
              )
            }
          }
        }
      }
    }
  }
}
