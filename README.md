# Complete CI/CD with Terraform
## Tools and Technologies used:
1. Terraform
2. jenkins
3. Docker
4. AWS
5. GIt
6. Java
7. Maven
8. Dockerhub
   
This project uses Jenkins to take the app's source code from commit to deployment. It uses Jenkins to run the CI/CD pipeline. Jenkins in turn uses the terraform files in this repository to provision servers on AWS to deploy the app using the `docker-compose.yaml` file in this repository. The terraform files use AWS' official provider to define resources that need to be provisioned.


The CI/CD pipeline performs the following steps:
1. It increments the patch version at the beginning before starting a new build using an `mvn` command. 
2. It builds artifacts (jar files) from the source code. 
3. It uses the Dockerfile to build the docker image and then pushes it to dockerhub
4. It runs the ``terraform apply`` command to provision the resources defined in the terraform files in AWS. The pipeline job uses AWS credentials stored in the Jenkins server to let terraform authenticate with AWS to provision these resources. Public IP Address of the provisioned server is the output of the root module of terraform files in this repo. The state is stored remotely in an S3 bucket so that we don't provision the server if it already exists.
5. It uses ``sshagent``, which is a Jenkins plugin to ssh into the provisioned server by reading the public IP address of the server from terraform's output. The ssh is performed using an SSH Key pair. The private key is available as a credential in the Jenkins server. The ``docker-compose.yaml`` file is copied to the provisioned server using scp. It then starts the app using docker-compose command. For simplicity this command is run via `server-cmds.sh` which is also copied to the provisioned aws server using scp.