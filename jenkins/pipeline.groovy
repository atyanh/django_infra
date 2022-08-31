pipeline {
  environment {
    registry = "localhost:8082/repository/django/web"
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
          dockerImage = docker.build registry + ":$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        sh "docker login localhost:8082 -u admin -p admin123 && docker push $registry:$BUILD_NUMBER"
      }
    }

    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}

