pipeline {
  agent any

  options {
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')
  }

  stages {
    stage('Build Containers') {
      steps { sh 'make build' }
    }
    stage('Test Services') {
      steps { sh 'make test' }
    }
    stage('Teardown Containers') {
      steps { sh 'make teardown' }
    }
  }
}