#!user/bin/env groovy
library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/ujwalshende/jenkins-shared-library.git',
    credentialsId: 'github-password' ]
)


pipeline{
    agent any
    tools{
        maven 'maven-3.9.16'
    }
    environment{
        IMAGE_NAME = 'uds10/demo-app:jma-1.0'
    }
    stages {
        stage("increment version") {
            steps{
                script{
                    echo "incrementing app version..."
                    sh 'mvn build-helper:parse-version versions:set \
                    -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                    versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "uds10/demo-app:$version-$BUILD_NUMBER" 
                }
            }
        }
        stage("build jar") {
            steps{
                script{
                    echo 'building the app...'
                    buildJar()

                }
            }
        }
        stage("build and push image") {
            steps{
                script{
                    dockerLogin()
                    echo 'building and pushing the image'
                    buildImage(env.IMAGE_NAME)
                    // dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }

            }
        }
        stage("provision server"){
            environment{
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key')
                TF_VAR_env_prefix = 'test'
            }
            steps{
                script{
                    dir('terraform'){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh (
                            script: "terraform output ec2_public_ip",
                            returnStdout: true 
                        ).trim()
                    }
                }
            }
        }
        stage("deploy"){
            environment{
                DOCKER_CREDS = credentials('docker-hub-repo')
            }
            steps{
                script{
                    echo "waiting for EC2 server to initialise"  
                    sleep(time: 90, unit: "SECONDS")
                    echo 'deploying to ec2 instance...'
                    echo "${EC2_PUBLIC_IP}"
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"  
                    def ec2_instance = "ec2-user@${EC2_PUBLIC_IP}"
                    sshagent(credentials: ['server-ssh-key'], executable: '') {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2_instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2_instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2_instance} ${shellCmd}"
                    }

                }
            }
        }
    }
}
