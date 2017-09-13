pipeline {
  agent any

  environment {
    EXCLUDE = 'Products.ZSPARQLMethod sparql-client eea.google'
  }

  stages {
    stage('Tests') {
      steps {
        node(label: 'docker-1.13') {

          sh '''
echo "WARNING: Building eeacms/kgs is disabled due to Docker-in-Docker instability Pulling image from DockerHub"
echo "docker build -t eeacms/kgs ."
docker pull eeacms/kgs'''

          sh '''
echo "WARNING: Building eeacms/kgs-devel is disabled due to Docker-in-Docker instability. Pulling image from DockerHub"
echo "docker build -t eeacms/kgs-devel devel"
docker pull eeacms/kgs-devel'''

          sh '''
echo "INFO: Running tests"
docker run -i --net=host --name="$BUILD_TAG" -e EXCLUDE="$EXCLUDE" eeacms/kgs-devel /debug.sh tests'''

          sh '''
echo "INFO: Cleanning up"
docker rm -v $BUILD_TAG'''
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
