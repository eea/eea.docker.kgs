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
      environment {
        IMAGE_NAME = BUILD_TAG.toLowerCase()
      }
      steps {
        node(label: 'clair') {
          script {
            try {
              checkout scm
              sh '''sed -i "s|eeacms/kgs|${IMAGE_NAME}|g" devel/Dockerfile'''
              sh "docker build -t ${IMAGE_NAME} ."
              sh "docker build -t ${IMAGE_NAME}-devel devel"
              sh "docker run -i --name=${IMAGE_NAME} -e EXCLUDE=${EXCLUDE} -e GIT_BRANCH=${params.TARGET_BRANCH} ${IMAGE_NAME}-devel /debug.sh tests"
            } finally {
              sh script: "docker rm -v ${IMAGE_NAME}", returnStatus: true
              sh script: "docker rmi ${IMAGE_NAME}", returnStatus: true
              sh script: "docker rmi ${IMAGE_NAME}-devel", returnStatus: true     
            }
          }
        }

      }
    }
  }

  post {
    always {
      cleanWs(cleanWhenAborted: true, cleanWhenFailure: true, cleanWhenNotBuilt: true, cleanWhenSuccess: true, cleanWhenUnstable: true, deleteDirs: true)
    }
    changed {
      script {
        def details = """<h1>${env.JOB_NAME} - Build #${env.BUILD_NUMBER} - ${currentBuild.currentResult}</h1>
                         <p>Check console output at <a href="${env.BUILD_URL}/display/redirect">${env.JOB_BASE_NAME} - #${env.BUILD_NUMBER}</a></p>
                      """
        emailext(
        subject: '$DEFAULT_SUBJECT',
        body: details,
        attachLog: true,
        compressLog: true,
        recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'CulpritsRecipientProvider']]
        )
      }
    }
  }
}
