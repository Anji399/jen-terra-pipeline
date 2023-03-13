pipeline {
    agent any
    environment {
        PATH = "/usr/local/bin/:$PATH"
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
                sh 'cd C:/Users/userMusic/eb-tomcat-snakes'
                sh 'terraform version'
                sh 'packer version'
            }
        }
        stage('perform packer build'){
            steps {
                sh 'packer build -var-file packer-vars-dev.json packer.json | tee output.txt'
                            sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                            sh "echo \$(cat ami.txt) > ami.txt"
                            script {
                                def AMIID = readFile('ami.txt').trim()
                                sh 'echo "" >> variables.tf'
                                sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                            }
            }
        }   

    }
}            
