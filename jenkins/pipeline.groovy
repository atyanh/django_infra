pipeline {
    agent any
    stages {
        stage('pull update') {
            steps {
                sh 'echo Pulling updates..'
            }
        }
	stage('build') {
            steps {
                sh 'echo building..'
            }
        }
	stage('update') {
            steps {
                sh 'echo Updating..'
            }
        }

    }
}
