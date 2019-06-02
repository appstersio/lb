pipeline {
  agent any

  options {
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5')
  }

  stages {
    stage('make build') {
      steps { sh 'make build' }
    }
    stage('make release-up') {
      steps { sh 'make release-up' }
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
    stage('make publish') {
      when {
        branch 'master'
        expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
      }
      steps { sh 'make publish' }
    }
  }
}