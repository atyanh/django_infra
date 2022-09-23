pipeline {
  environment {
    registry = "localhost:8082/repository/django/web"
    nexus_password = credentials('nexus_password')
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
          sh "echo $nexus_password"
          sh "docker build . -t $registry:$BUILD_NUMBER"
          sh "docker build . -t $registry:latest"
        }
      }
    }
    stage('Push Image') {
      steps{
        sh "docker login localhost:8082 -u admin -p $nexus_password && docker push $registry:$BUILD_NUMBER && docker push $registry:latest"
      }
    }

    stage('Pushing Image') {
      steps{
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
        sh "docker run  -e 'AWS_ACCESS_KEY_ID=AKIAVPVJ5V2ZA5KKRA22' -e 'AWS_SECRET_ACCESS_KEY=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' -v /home/ubuntu/django_web.yml:/root/django_web.yml --rm bearengineer/awscli-kubectl /bin/sh -c '/usr/bin/aws eks update-kubeconfig --region us-east-1 --name eks_cluster && kubectl apply -f /root/django_web.yml'"                           
      }
    }
  }
}

