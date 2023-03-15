pipeline {
    agent any
    environment {
    registry = 'mvpar/devops20'
    registryCredential = 'dockerhub_id'
    dockerImage = ''
    PACKER_BUILD = 'NO'
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
        stage('perform packer build') {
            when {
                expression {
                    env.PACKER_BUILD == 'YES'
                }
            }    
            steps {
                sh 'packer build -var-file packer-vars.json packer.json | tee output.txt'
                sh "tail -2 output.txt | head -2 | awk 'match(\$0, /ami-.*/) { print substr(\$0, RSTART, RLENGTH) }' > ami.txt"
                sh "echo \$(cat ami.txt) > ami.txt"
                script {
                    def AMIID = readFile('ami.txt').trim()
                    sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                }
            }    
        }
        stage('Use Default Packer Image') {
            when {
                expression {
                    env.PACKER_BUILD == 'NO' 
                }
            }    
            steps {
                dir('terraform') {
                script {
                    def AMIID = 'ami-03bef618b5b4b5846'
                    sh "echo variable \\\"imagename\\\" { default = \\\"$AMIID\\\" } >> variables.tf"
                    sh 'cat variables.tf | grep -i imagename'
                }
                }
            }
        }
        stage('Terraform deploy') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform taint null_resource.docker_deploy'
                    sh 'terraform apply --auto-approve'
                }
            }
        }
        stage('Deploy docker image') {
            steps {
                dir('terraform'){
                    script {
                        def DOCKER_HOST = readFile('publicip.txt').trim()
                        sh "docker -H tcp://$DOCKER_HOST:2375 stop nginx001"
                        sh "docker -H tcp://$DOCKER_HOST:2375 run --rm -dit --name nginx001 -p 8080:8080 mvpar/devops20:$BUILD_NUMBER"
                        sh 'sleep 10'
                    }
                }
            }
        }
        stage('Validate Deployment') {
            steps {
                dir('terraform') {
                   script{
                      def DOCKER_HOST = readFile('publicip.txt').trim()
                      sh "curl -sL http://$DOCKER_HOST:8080/mywebapp/ || exit 1"
                    }  
                }
            }
        }        
    } 
}               
