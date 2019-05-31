pipeline {
  agent any

  options {
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')
  }

  stages {
    stage('make build') {
      steps { sh 'make build' }
    }
    stage('make up') {
      steps { sh 'make up' }
    }
    stage('make netcat') {
      steps { sh 'make netcat' }
    }
    stage('make test') {
      steps { sh 'make test' }
    }
    stage('make teardown') {
      steps { sh 'make teardown' }
    }
  }
}