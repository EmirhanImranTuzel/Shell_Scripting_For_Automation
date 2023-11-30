#!/bin/bash

# Set the desired locale to avoid locale-related issues.

echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment
echo 'export LANG=en_US.UTF-8' >> /etc/environment
echo 'export LC_COLLATE=C' >> /etc/environment
echo 'export LC_CTYPE=en_US.UTF-8' >> /etc/environment

sudo yum update -y && sudo yum upgrade -y

# Install Terraform;

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
