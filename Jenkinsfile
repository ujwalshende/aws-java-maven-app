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
        stage("deploy"){
            steps{
                script{
                    echo 'deploying to ec2 instance...'
                    def shellCmd = "bash ./server-cmds.sh"
                    
                    sshagent(credentials: ['ec2-server-key'], executable: '') {
                        sh "scp server-cmds.sh ec2-user@3.66.155.131:/home/ec2-user"
                        sh "scp docker-compose.yaml ec2-user@3.66.155.131:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@3.66.155.131 ${shellCmd}"
                    }

                }
            }
        }
    }
}
