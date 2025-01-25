#!/bin/bash
set -e

# Define variables
AWS_REGION="us-east-1"
CONTAINER_NAME="simple-python-app"
PORT=5000  # Flask app listening port

# Fetch credentials and ECR URL from Parameter Store
echo "Fetching credentials from Parameter Store..."
AWS_ACCESS_KEY_ID=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-access-key-id" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)
AWS_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-secret-access-key" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)
ECR_URI=$(aws ssm get-parameter --name "/myaap/docker-registry/url" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# Configure AWS credentials for Docker login
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

echo "Logging into Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

echo "Pulling the latest image from ECR..."
docker pull $ECR_URI/$CONTAINER_NAME:latest

echo "Starting a new container with the latest image..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:5000 \
  $ECR_URI/$CONTAINER_NAME:latest

echo "Container started successfully!"
