pipeline {
  environment {
    registry = "localhost:8082/repository/django/web"
    nexus_password = "admin119"
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
          sh "docker build . -t $registry:$BUILD_NUMBER"
        }
      }
    }
    stage('Deploy Image') {
      steps{
        sh "docker login localhost:8082 -u admin -p $nexus_password && docker push $registry:$BUILD_NUMBER"
      }
    }

    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}

