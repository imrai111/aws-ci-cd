#!/bin/bash
set -e

# Define variables
AWS_REGION="us-east-1"
S3_BUCKET="simple-python-bucket"
ARTIFACT_PATH="artifacts/docker-image.tar.gz"
CONTAINER_NAME="simple-python-app"
PORT=5000  # Flask app listening port

# Export AWS region
export AWS_REGION

# Fetch AWS credentials from Parameter Store
echo "Fetching credentials from Parameter Store..."
AWS_ACCESS_KEY_ID=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-access-key-id" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)
AWS_SECRET_ACCESS_KEY=$(aws ssm get-parameter --name "/myapp/docker-credentials/aws-secret-access-key" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# Configure AWS credentials for S3 access
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

# Download the Docker image tar.gz from S3
echo "Downloading Docker image tar.gz from S3..."
aws s3 cp s3://$S3_BUCKET/$ARTIFACT_PATH docker-image.tar.gz

# Load the Docker image from the tar.gz file
echo "Loading Docker image from tar.gz file..."
docker load -i docker-image.tar.gz

# Start the Docker container
echo "Starting a new container with the loaded image..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:5000 \
  simple-python-app:latest

echo "Container started successfully!"