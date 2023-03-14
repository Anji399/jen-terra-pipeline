pipeline {
    agent any
    environment {
    registry = 'mvpar/devops20'
    registryCredential = 'dockerhub_id'
    dockerImage = ''
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
               s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'devops20artifact', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: true, selectedRegion: 'ap-south-1', showDirectlyInBrowser: false, sourceFile: '*.war', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'jen-s3-profile', userMetadata: [] 
            }
        }
        stage('Build docker image') {
            steps {
                script {
                  dockerImage = docker.build registry + ":$BUILD_NUMBER"
              }  
           }    
        }
        stage('Push docker image') {
            steps {
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }    
            }    
        }
        stage('check terraform and packer versions') {
            steps {
                script {
                  sh 'terraform version'
                  sh 'packer version'
                }
            }
        }
        stage('perform packer build') {
            steps {
                sh 'packer build -var-file packer-vars-dev.json packer.json | tee output.txt'
                sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                sh "echo \$(cat ami.txt) > ami.txt"
                script {
                    def AMIID = readFile('ami.txt').trim()
                    sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                }
            }
        }
    } 
}               
