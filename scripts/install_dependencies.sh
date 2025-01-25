#!/bin/bash

echo "Installing Docker..."
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

echo "Docker installation complete."
