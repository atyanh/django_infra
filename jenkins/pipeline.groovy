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
                sh 'cd django'
                sh 'docker build . -t localhost:8082/repository/django/web:latest'
                sh 'ls'
            }
        }
	    stage('update') {
            steps {
                sh 'echo Updating..'
            }
        }
    

    }
}
