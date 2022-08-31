pipeline {
  environment {
    registry = "localhost:8082"
    repository = "localhost:8082/repository/django/web"
    registryCredential = 'nexus'
    dockerImage = ''
  }
  agent any
  stages {
    stage('Cloning Git') {
      steps {
        git 'https://github.com/atyanh/django.git'
      } 
    }
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build $repository + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( $registry, registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $repository:$BUILD_NUMBER"
      }
    }
  }
}

