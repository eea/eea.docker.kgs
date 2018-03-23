pipeline {
  agent any

  environment {
    EXCLUDE = 'eea.google'
  }

  parameters {
    string(defaultValue: '', description: 'Run tests with GIT_BRANCH env enabled', name: 'TARGET_BRANCH')
  }

  stages {
    stage('Build & Test') {
      steps {
        node(label: 'clair') {
          script {
            try {
              checkout scm
              sh '''sed -i "s|eeacms/kgs|${BUILD_TAG}|g" devel/Dockerfile'''
              sh "docker build -t ${BUILD_TAG} ."
              sh "clair-scanner --ip=`hostname` --clair=https://clair.eea.europa.eu -t=Critical ${BUILD_TAG}"
              sh "docker build -t ${BUILD_TAG}-devel devel"
              sh "clair-scanner --ip=`hostname` --clair=https://clair.eea.europa.eu -t=Critical ${BUILD_TAG}-devel"
              sh "docker run -i --name=${BUILD_TAG} -e EXCLUDE=${EXCLUDE} -e GIT_BRANCH=${params.TARGET_BRANCH} ${BUILD_TAG}-devel /debug.sh tests"
            } finally {
              sh "docker rm -v ${BUILD_TAG}"
              sh "docker rmi ${BUILD_TAG}-devel"
              sh "docker rmi ${BUILD_TAG}"
            }
          }
        }

      }
    }
  }

  post {
    changed {
      script {
        def url = "${env.BUILD_URL}/display/redirect"
        def status = currentBuild.currentResult
        def subject = "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
        def summary = "${subject} (${url})"
        def details = """<h1>${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${status}</h1>
                         <p>Check console output at <a href="${url}">${env.JOB_BASE_NAME} - #${env.BUILD_NUMBER}</a></p>
                      """

        def color = '#FFFF00'
        if (status == 'SUCCESS') {
          color = '#00FF00'
        } else if (status == 'FAILURE') {
          color = '#FF0000'
        }
        slackSend (color: color, message: summary)
        emailext (subject: '$DEFAULT_SUBJECT', to: '$DEFAULT_RECIPIENTS', body: details)
      }
    }
  }
}
