pipeline {
  agent {
    node {
      label 'docker-1.10'
    }
    
  }
  stages {
    stage('Build Master') {
      steps {
        sh 'docker build -t eeacms/kgs .'
      }
    }
    stage('Build Devel') {
      steps {
        sh 'docker build -t eeacms/kgs:devel devel'
      }
    }
    stage('Tests') {
      steps {
        sh 'docker run --rm eeacms/kgs:devel bin/test -s eea.plonebuildout.profile'
      }
    }
    stage('Cleanup') {
      steps {
        sh 'docker rmi eeacms/kgs:devel eeacms/kgs'
      }
    }
  }
}