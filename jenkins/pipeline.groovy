pipeline {
    agent any
    stages {
        stage('pull update') {
            steps {
                sh 'rm -rf django/'
                sh 'echo Pulling updates..'
                sh 'git clone https://github.com/atyanh/django.git'
            }
        }
	    stage('build') {
            steps {

                sh 'echo building..'
                sh 'docker build ./django/ -t localhost:8082/repository/django/web:latest'
                sh 'ls'
            }
        }
	    stage('push to repository') {
            steps {
                sh 'docker push localhost:8082/repository/django/web:latest'
            }
        }
    

    }
}
