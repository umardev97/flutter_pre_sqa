pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Dependencies') {
      steps {
        sh 'dart pub get'
      }
    }
    stage('Validate') {
      steps {
        sh 'dart run flutter_pre_sqa ci --coverage --json'
        sh 'dart analyze'
      }
    }
  }
}
