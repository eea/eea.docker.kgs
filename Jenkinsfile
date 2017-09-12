pipeline {
  agent any
  stages {
    stage('Tests') {
      steps {
        node(label: 'docker-1.13') {
          sh '''echo "WARNING: Building eeacms/kgs is disabled due to Docker-in-Docker instability Pulling image from DockerHub"
echo "docker build -t eeacms/kgs ."
docker pull eeacms/kgs'''
          sh '''echo "WARNING: Building eeacms/kgs-devel is disabled due to Docker-in-Docker instability. Pulling image from DockerHub"
echo "docker build -t eeacms/kgs-devel devel"
docker pull eeacms/kgs-devel'''
          sh '''echo "INFO: Running tests"
docker run -i --net=host --name="$BUILD_TAG" -e EXCLUDE="$EXCLUDE" eeacms/kgs-devel /debug.sh tests'''
          sh '''echo "INFO: Cleanning up"
docker rm -v $BUILD_TAG'''
        }
        
      }
    }
  }
  environment {
    EXCLUDE = 'Products.ZSPARQLMethod sparql-client eea.google'
  }
}
