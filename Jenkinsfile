pipeline {
    agent any
    environment {
        registry = "mvpar/devops20"
        registryCredential = 'dockerhub_id'
        dockerimage = ''
    }
    stages {
        stage('Build Java Code') {
            steps {
                echo "${BUILD_NUMBER}"
                sh 'rm -f *.war && bash build.sh && mv ROOT.war ROOT${BUILD_NUMBER}.war'
                sh 'ls -la'
            }
        }
        stage('Push Artifact to S3') {
            steps {
                s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'devops20artifact', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'ap-south-1', showDirectlyInBrowser: false, sourceFile: '*.war', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'devops-jen-s3-profile', userMetadata: []
            }
        }
        stage('Push docker image') {
            steps {
                script {
                    docker.withRegistry('',registryCredential)
                    dockerImage.Push()
                }
            }
        }
    }
}            
