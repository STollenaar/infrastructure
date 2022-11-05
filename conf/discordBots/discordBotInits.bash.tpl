#!/bin/bash
# Making sure the session manager installed
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm

# Installing utils
yum install -y yum-utils jq git amazon-cloudwatch-agent

# Configuring and running cloudwatch-agent
# echo "${cloudwatchAgentSchema}" | base64 -d - > /opt/aws/amazon-cloudwatch-agent/bin/config.json
# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# Installing docker
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
chkconfig docker on

# Insalling docker compose
curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Setting up the discordBots
docker network create dbNet
docker volume create databases

aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin "${accountID}.dkr.ecr.ca-central-1.amazonaws.com"

echo "${dockerCompose}" | base64 -d - > /home/ec2-user/docker-compose.yml
chown ec2-user /home/ec2-user/docker-compose.yml

docker-compose up -d
