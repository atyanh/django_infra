pipeline {
    agent any
    stages {
        stage('pull update') {
            steps {
                sh 'echo Pulling updates..'
                sh 'git clone https://github.com/atyanh/django.git'
            }
        }
	stage('build') {
            steps {
                sh 'echo building..'
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
