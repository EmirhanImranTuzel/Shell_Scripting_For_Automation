#!/bin/bash

# Set the desired locale to avoid locale-related issues.

echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'export LANG=en_US.UTF-8' >> /etc/environment
echo 'export LC_COLLATE=C' >> /etc/environment
echo 'export LC_CTYPE=en_US.UTF-8' >> /etc/environment

# Customize prompt;

echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[0;32m\]\h\[\e[m\]@\[\e[0;34m\]\w\[\e[m\]\$ '" | sudo tee -a /etc/bashrc > /dev/null

# Install requirements;

yum update -y && yum upgrade -y
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user
source ~/.bashrc
