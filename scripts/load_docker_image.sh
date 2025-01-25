#!/bin/bash

ARTIFACT_PATH="/home/ec2-user/deployment/docker-image.tar.gz"

echo "Loading Docker image from artifact..."
docker load < $ARTIFACT_PATH

if [ $? -eq 0 ]; then
  echo "Docker image loaded successfully."
else
  echo "Failed to load Docker image."
  exit 1
fi
