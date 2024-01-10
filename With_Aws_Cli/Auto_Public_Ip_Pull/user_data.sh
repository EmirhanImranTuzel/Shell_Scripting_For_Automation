#!/bin/bash

# Set the desired locale to avoid locale-related issues.

echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'export LANG=en_US.UTF-8' >> /etc/environment
echo 'export LC_COLLATE=C' >> /etc/environment
echo 'export LC_CTYPE=en_US.UTF-8' >> /etc/environment

sudo yum update -y && sudo yum upgrade -y

echo "PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[0;32m\]\h\[\e[m\]@\[\e[0;34m\]\w\[\e[m\]\$ '" >> ~/.bashrc && source ~/.bashrc


# Install Terraform;

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

# Install Docker;

