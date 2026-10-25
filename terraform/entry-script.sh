#!/bin/bash
# Update and install Docker
yum update -y
yum install -y docker

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add the default user to the docker group (optional, for later SSH access)
usermod -aG docker ec2-user

# install docker-compose
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose