pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '60'))
    parallelsAlwaysFailFast()
    disableConcurrentBuilds()
  }

    triggers {
      cron(BRANCH_NAME == 'main' ? 'H 9 * * 6' : '')
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
    stage('Build base image (cache)') {
      when {
        branch 'main'
        not {
          anyOf {
            triggeredBy 'TimerTrigger'
            triggeredBy cause: 'UserIdCause'
            changeRequest()
          }
        }
      }
      steps {
        script {
          buildDockerImage(
            dockerFile: '.docker/base.Dockerfile',
            tag: 'base',
            altTag: 'latest',
            buildArgs: ["BUILD_IMAGE=${REGISTRY}/${IMAGE_OWNER}/python:3.11-bookworm-venv-builder"],
            useCache: true
          )
        }
      }
    }

    stage('Build base image (no cache)') {
      when {
        branch 'main'
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
            altTag: 'latest',
            buildArgs: ["BUILD_IMAGE=${REGISTRY}/${IMAGE_OWNER}/python:3.11-bookworm-venv-builder"]
          )
        }
      }
    }

    stage('Build k8s image (cache)') {
      when {
        branch 'main'
        not {
          anyOf {
            triggeredBy 'TimerTrigger'
            triggeredBy cause: 'UserIdCause'
            changeRequest()
          }
        }
      }
      steps {
        script {
          buildDockerImage(
            dockerFile: '.docker/k8s.Dockerfile',
            tag: 'k8s',
            buildArgs: ["RUNNER_IMAGE=${IMAGE_FULLNAME}:base"],
            useCache: true
          )
        }
      }
    }

    stage('Build k8s image (no cache)') {
      when {
        branch 'main'
        anyOf {
          triggeredBy 'TimerTrigger'
          triggeredBy cause: 'UserIdCause'
        }
      }
      steps {
        script {
          buildDockerImage(
            dockerFile: '.docker/k8s.Dockerfile',
            tag: 'k8s',
            buildArgs: ["RUNNER_IMAGE=${IMAGE_FULLNAME}:base"]
          )
        }
      }
    }

    stage('Build infra image (cache)') {
      when {
        branch 'main'
        not {
          anyOf {
            triggeredBy 'TimerTrigger'
            triggeredBy cause: 'UserIdCause'
            changeRequest()
          }
        }
      }
      steps {
        script {
          buildDockerImage(
            dockerFile: '.docker/infra.Dockerfile',
            tag: 'infra',
            buildArgs: ["RUNNER_IMAGE=${IMAGE_FULLNAME}:k8s"],
            useCache: true
          )
        }
      }
    }

    stage('Build infra image (no cache)') {
      when {
        branch 'main'
        anyOf {
          triggeredBy 'TimerTrigger'
          triggeredBy cause: 'UserIdCause'
        }
      }
      steps {
        script {
          buildDockerImage(
            dockerFile: '.docker/infra.Dockerfile',
            tag: 'infra',
            buildArgs: ["RUNNER_IMAGE=${IMAGE_FULLNAME}:k8s"]
          )
        }
      }
    }
  }

  post {
    always {
      emailext(
        to: '$DEFAULT_RECIPIENTS',
        subject: '$DEFAULT_SUBJECT',
        body: '$DEFAULT_CONTENT'
      )
    }
  }
}
