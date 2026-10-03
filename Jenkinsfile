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
        stage("deploy"){
            steps{
                script{
                    echo 'deploying to ec2 instance...'
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"  
                    def ec2_instance = "ec2-user@3.66.155.131"
                    sshagent(credentials: ['ec2-server-key'], executable: '') {
                        sh "scp server-cmds.sh ${ec2_instance}:/home/ec2-user"
                        sh "scp docker-compose.yaml ${ec2_instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2_instance} ${shellCmd}"
                    }

                }
            }
        }
        stage('commit version update'){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'github-password', passwordVariable: 'PASS', usernameVariable: 'USER'), string(credentialsId: 'gitlab-token', variable: 'GITHUB_TOKEN')]){
                        sh 'git config user.email "jenkins@example.com"'
                        sh 'git config user.name "jenkins"'
                        sh 'git status'
                        sh 'git branch'
                        sh 'git config --list'
                        sh "git remote set-url origin https://${USER}:${GITHUB_TOKEN}@github.com/ujwalshende/aws-java-maven-app.git"
                        sh "git add ."
                        sh 'git commit -m "ci: version bump"'
                        sh "git push origin HEAD:master"
                    }
                }
            }
        }
    }
}
