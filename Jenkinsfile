pipeline {
    agent any
    
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
        stage('Build docker image') {
            steps {
                sh 'docker build -t mvpar/devops20 .'  
           }    
       }
        stage('Push docker image') {
            steps {
              withCredentials([string(credentialsId: 'dockerize', variable: 'dockerr')]) {
              sh "docker login -u mvpar -p ${dockerr}"
            }  
              sh 'docker push mvpar/devops20'
            }    
        }
        stage('check terraform and packer versions') {
            steps {
                sh 'terraform version'
                sh 'packer version'
            }
        }

    }
}            
