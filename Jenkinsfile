pipeline {
    agent any
    stages {
        stage('Build Java Code') {
            steps {
                sh 'bash build.sh'
                sh 'ls -la'
            }
        }
    }
}