// pipeline {
//     agent any
//     stages {
//         stage('pull update') {
//             steps {
//                 sh 'rm -rf django/'
//                 sh 'echo Pulling updates..'
//                 sh 'git clone https://github.com/atyanh/django.git'
//             }
//         }
// 	    stage('build') {
//             steps {
//                 sh 'docker rmi localhost:8082/repository/django/web:latest'
//                 sh 'docker login localhost:8082 -u admin -p admin123'
//                 sh 'docker build ./django/ -t localhost:8082/repository/django/web:latest'
//                 sh 'ls'
//             }
//         }
// 	    stage('push to repository') {
//             steps {
//                 sh 'docker push localhost:8082/repository/django/web:latest'
//             }
//         }
    

//     }
// }



pipeline {
  environment {
    registry = "localhost:8082/repository/django"
    registryCredential = 'docker'
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
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}