#!/bin/bash
set -e

dnf update -y
dnf install -y \
  amazon-ssm-agent \
  git \
  unzip \
  zip \
  tree \
  nano \
  vim \
  python3 \
  python3-pip

pip3 install --no-cache-dir ansible

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
