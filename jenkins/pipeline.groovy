pipeline {
  environment {
    registry = "localhost:8082/repository/django/web"
    nexus_password = credentials('nexus_password')
    aws_access_key_id = credentials('aws_access_key_id')
    aws_secret_access_key = credentials('aws_secret_access_key')
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
          sh "docker build . -t $registry:latest"
        }
      }
    }

    stage('Pushing Image') {
      steps{
        sh "docker login localhost:8082 -u admin -p $nexus_password && docker push $registry:$BUILD_NUMBER && docker push $registry:latest"
        sh "docker login localhost:8082 -u admin -p $nexus_password && docker push $registry:$BUILD_NUMBER"
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER && docker rmi $registry:latest"
      }
    }


    stage('Deploy on EKS') {
      steps {
        sh "docker run  -e AWS_ACCESS_KEY_ID=$aws_access_key_id -e AWS_SECRET_ACCESS_KEY=$aws_secret_access_key -v /home/ubuntu/django_web.yml:/root/django_web.yml --rm bearengineer/awscli-kubectl /bin/sh -c '/usr/bin/aws eks update-kubeconfig --region us-east-1 --name eks_cluster && kubectl apply -f /root/django_web.yml'"                           
      }
    }
  }
}

