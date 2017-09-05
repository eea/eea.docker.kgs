pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        node(label: 'docker-1.13') {
          sh 'docker build -t eeacms/kgs .'
        }
        
      }
    }
  }
}